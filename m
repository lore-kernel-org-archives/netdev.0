From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 17/37] net: use get/put_endian helpers
Date: Thu, 29 May 2008 13:18:32 -0700
Message-ID: <1212092312.28403.119.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>,
	linux-arch <linux-arch@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:65440 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbYE2USj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 16:18:39 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1839904ika.5
        for <netdev@vger.kernel.org>; Thu, 29 May 2008 13:18:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/8139cp.c                 |    4 ++--
 drivers/net/8139too.c                |    6 +++---
 drivers/net/bfin_mac.c               |    8 ++++----
 drivers/net/forcedeth.c              |    4 ++--
 drivers/net/mlx4/eq.c                |    2 +-
 drivers/net/mlx4/fw.c                |   18 +++++++++---------
 drivers/net/mlx4/qp.c                |    2 +-
 drivers/net/myri10ge/myri10ge.c      |    2 +-
 drivers/net/netxen/netxen_nic_init.c |    4 ++--
 drivers/net/netxen/netxen_nic_niu.c  |   12 ++++++------
 drivers/net/niu.c                    |   12 ++++++------
 drivers/net/pppol2tp.c               |   12 ++++++------
 drivers/net/rrunner.c                |    8 ++++----
 drivers/net/sc92031.c                |    2 +-
 drivers/net/sunhme.c                 |    4 ++--
 drivers/net/tulip/dmfe.c             |    6 +++---
 drivers/net/tun.c                    |    2 +-
 17 files changed, 54 insertions(+), 54 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a453eda..dad90f1 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1018,8 +1018,8 @@ static void cp_init_hw (struct cp_private *cp)
 	cpw8_f (Cfg9346, Cfg9346_Unlock);
 
 	/* Restore our idea of the MAC address. */
-	cpw32_f (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
-	cpw32_f (MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
+	cpw32_f(MAC0 + 0, get_le32((__le32 *)(dev->dev_addr + 0)));
+	cpw32_f(MAC0 + 4, get_le32((__le32 *)(dev->dev_addr + 4)));
 
 	cp_start_hw(cp);
 	cpw8(TxThresh, 0x06); /* XXX convert magic num to a constant */
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..27b72b0 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1373,8 +1373,8 @@ static void rtl8139_hw_start (struct net_device *dev)
 	/* unlock Config[01234] and BMCR register writes */
 	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
 	/* Restore our idea of the MAC address. */
-	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
-	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));
+	RTL_W32_F (MAC0 + 0, get_le32((__le32 *)(dev->dev_addr + 0)));
+	RTL_W32_F (MAC0 + 4, get_le16((__le16 *)(dev->dev_addr + 4)));
 
 	/* Must enable Tx/Rx before setting transfer thresholds! */
 	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
@@ -1945,7 +1945,7 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		rmb();
 
 		/* read size+status of next frame from DMA ring buffer */
-		rx_status = le32_to_cpu (*(__le32 *) (rx_ring + ring_offset));
+		rx_status = get_le32((__le32 *)(rx_ring + ring_offset));
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 4144343..9eed06a 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -533,8 +533,8 @@ void setup_system_regs(struct net_device *dev)
 
 static void setup_mac_addr(u8 *mac_addr)
 {
-	u32 addr_low = le32_to_cpu(*(__le32 *) & mac_addr[0]);
-	u16 addr_hi = le16_to_cpu(*(__le16 *) & mac_addr[4]);
+	u32 addr_low = get_le32((__le32 *)&mac_addr[0]);
+	u16 addr_hi = get_le16((__le16 *)&mac_addr[4]);
 
 	/* this depends on a little-endian machine */
 	bfin_write_EMAC_ADDRLO(addr_low);
@@ -973,8 +973,8 @@ static int __init bfin_mac_probe(struct platform_device *pdev)
 	lp = netdev_priv(ndev);
 
 	/* Grab the MAC address in the MAC */
-	*(__le32 *) (&(ndev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
-	*(__le16 *) (&(ndev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
+	put_le32(bfin_read_EMAC_ADDRLO(), &ndev->dev_addr[0]);
+	put_le16(bfin_read_EMAC_ADDRHI(), &ndev->dev_addr[4]);
 
 	/* probe mac */
 	/*todo: how to proble? which is revision_register */
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 9eca97f..b1930b4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2938,8 +2938,8 @@ static void nv_set_multicast(struct net_device *dev)
 				walk = dev->mc_list;
 				while (walk != NULL) {
 					u32 a, b;
-					a = le32_to_cpu(*(__le32 *) walk->dmi_addr);
-					b = le16_to_cpu(*(__le16 *) (&walk->dmi_addr[4]));
+					a = get_le32((__le32 *)walk->dmi_addr);
+					b = get_le16((__le16 *)&walk->dmi_addr[4]);
 					alwaysOn[0] &= a;
 					alwaysOff[0] &= ~a;
 					alwaysOn[1] &= b;
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index e141a15..e276b68 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -458,7 +458,7 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 		for (i = 0; i < sizeof (struct mlx4_eq_context) / 4; ++i) {
 			if (i % 4 == 0)
 				printk("[%02x] ", i * 4);
-			printk(" %08x", be32_to_cpup(mailbox->buf + i * 4));
+			printk(" %08x", get_be32(mailbox->buf + i * 4));
 			if ((i + 1) % 4 == 0)
 				printk("\n");
 		}
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index d82f275..a59f28a 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -51,9 +51,9 @@ extern void __buggy_use_of_MLX4_PUT(void);
 		void *__p = (char *) (source) + (offset);	      \
 		switch (sizeof (dest)) {			      \
 		case 1: (dest) = *(u8 *) __p;	    break;	      \
-		case 2: (dest) = be16_to_cpup(__p); break;	      \
-		case 4: (dest) = be32_to_cpup(__p); break;	      \
-		case 8: (dest) = be64_to_cpup(__p); break;	      \
+		case 2: (dest) = get_be16(__p);     break;	      \
+		case 4: (dest) = get_be32(__p);     break;	      \
+		case 8: (dest) = get_be64(__p);     break;	      \
 		default: __buggy_use_of_MLX4_GET();		      \
 		}						      \
 	} while (0)
@@ -62,10 +62,10 @@ extern void __buggy_use_of_MLX4_PUT(void);
 	do {							      \
 		void *__d = ((char *) (dest) + (offset));	      \
 		switch (sizeof(source)) {			      \
-		case 1: *(u8 *) __d = (source);		       break; \
-		case 2:	*(__be16 *) __d = cpu_to_be16(source); break; \
-		case 4:	*(__be32 *) __d = cpu_to_be32(source); break; \
-		case 8:	*(__be64 *) __d = cpu_to_be64(source); break; \
+		case 1: *(u8 *) __d = (source);		break;	      \
+		case 2:	put_be16(source, __d);		break;	      \
+		case 4:	put_be32(source, __d);		break;	      \
+		case 8:	put_be64(source, __d);		break;	      \
 		default: __buggy_use_of_MLX4_PUT();		      \
 		}						      \
 	} while (0)
@@ -604,8 +604,8 @@ static void get_board_id(void *vsd, char *board_id)
 
 	memset(board_id, 0, MLX4_BOARD_ID_LEN);
 
-	if (be16_to_cpup(vsd + VSD_OFFSET_SIG1) == VSD_SIGNATURE_TOPSPIN &&
-	    be16_to_cpup(vsd + VSD_OFFSET_SIG2) == VSD_SIGNATURE_TOPSPIN) {
+	if (*(__be16 *)(vsd + VSD_OFFSET_SIG1) == cpu_to_be16(VSD_SIGNATURE_TOPSPIN) &&
+	    *(__be16 *)(vsd + VSD_OFFSET_SIG2) == cpu_to_be16(VSD_SIGNATURE_TOPSPIN)) {
 		strlcpy(board_id, vsd + VSD_OFFSET_TS_BOARD_ID, MLX4_BOARD_ID_LEN);
 	} else {
 		/*
diff --git a/drivers/net/mlx4/qp.c b/drivers/net/mlx4/qp.c
index ee5484c..af310bd 100644
--- a/drivers/net/mlx4/qp.c
+++ b/drivers/net/mlx4/qp.c
@@ -132,7 +132,7 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		context->log_page_size   = mtt->page_shift - MLX4_ICM_PAGE_SHIFT;
 	}
 
-	*(__be32 *) mailbox->buf = cpu_to_be32(optpar);
+	put_be32(optpar, (__be32 *)mailbox->buf);
 	memcpy(mailbox->buf + 8, context, sizeof *context);
 
 	((struct mlx4_qp_context *) (mailbox->buf + 8))->local_qpn =
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 5d035d0..ea8ca94 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -551,7 +551,7 @@ static int myri10ge_load_hotplug_firmware(struct myri10ge_priv *mgp, u32 * size)
 	}
 
 	/* check id */
-	hdr_offset = ntohl(*(__be32 *) (fw->data + MCP_HEADER_PTR_OFFSET));
+	hdr_offset = get_be32((__be32 *)(fw->data + MCP_HEADER_PTR_OFFSET));
 	if ((hdr_offset & 3) || hdr_offset + sizeof(*hdr) > fw->size) {
 		dev_err(dev, "Bad firmware file\n");
 		status = -EINVAL;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 45fa33e..45ce9d0 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -443,7 +443,7 @@ static int do_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
 		ret = do_rom_fast_read(adapter, addridx, &v);
 		if (ret != 0)
 			break;
-		*(__le32 *)bytes = cpu_to_le32(v);
+		put_le32(v, (__le32 *)bytes);
 		bytes += 4;
 	}
 
@@ -503,7 +503,7 @@ static int do_rom_fast_write_words(struct netxen_adapter *adapter,
 		int timeout = 0;
 		int data;
 
-		data = le32_to_cpu((*(__le32*)bytes));
+		data = get_le32((__le32 *)bytes);
 		ret = do_rom_fast_write(adapter, addridx, data);
 		if (ret < 0)
 			return ret;
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 1c852a7..511c694 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -612,13 +612,13 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 	for (i = 0; i < 10; i++) {
 		temp[0] = temp[1] = 0;
 		memcpy(temp + 2, addr, 2);
-		val = le32_to_cpu(*(__le32 *)temp);
+		val = get_le32((__le32 *)temp);
 		if (netxen_nic_hw_write_wx
 		    (adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), &val, 4))
 			return -EIO;
 
 		memcpy(temp, ((u8 *) addr) + 2, sizeof(__le32));
-		val = le32_to_cpu(*(__le32 *)temp);
+		val = get_le32((__le32 *)temp);
 		if (netxen_nic_hw_write_wx
 		    (adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), &val, 4))
 			return -2;
@@ -825,13 +825,13 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	switch (phy) {
 	case 0:
 	    memcpy(temp + 2, addr, 2);
-	    val = le32_to_cpu(*(__le32 *)temp);
+	    val = get_le32((__le32 *)temp);
 	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
 				&val, 4))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
-	    val = le32_to_cpu(*(__le32 *)temp);
+	    val = get_le32((__le32 *)temp);
 	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
 				&val, 4))
 		return -EIO;
@@ -839,13 +839,13 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 
 	case 1:
 	    memcpy(temp + 2, addr, 2);
-	    val = le32_to_cpu(*(__le32 *)temp);
+	    val = get_le32((__le32 *)temp);
 	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_1,
 				&val, 4))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
-	    val = le32_to_cpu(*(__le32 *)temp);
+	    val = get_le32((__le32 *)temp);
 	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_HI,
 				&val, 4))
 		return -EIO;
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 918f802..ed42d35 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3034,7 +3034,7 @@ static int niu_rx_pkt_ignore(struct niu *np, struct rx_ring_info *rp)
 
 		num_rcr++;
 
-		val = le64_to_cpup(&rp->rcr[index]);
+		val = get_le64(&rp->rcr[index]);
 		addr = (val & RCR_ENTRY_PKT_BUF_ADDR) <<
 			RCR_ENTRY_PKT_BUF_ADDR_SHIFT;
 		page = niu_find_rxpage(rp, addr, &link);
@@ -3079,7 +3079,7 @@ static int niu_process_rx_pkt(struct niu *np, struct rx_ring_info *rp)
 
 		num_rcr++;
 
-		val = le64_to_cpup(&rp->rcr[index]);
+		val = get_le64(&rp->rcr[index]);
 
 		len = (val & RCR_ENTRY_L2_LEN) >>
 			RCR_ENTRY_L2_LEN_SHIFT;
@@ -3199,7 +3199,7 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 	int i, len;
 
 	tp = (struct tx_pkt_hdr *) skb->data;
-	tx_flags = le64_to_cpup(&tp->flags);
+	tx_flags = get_le64(&tp->flags);
 
 	rp->tx_packets++;
 	rp->tx_bytes += (((tx_flags & TXHDR_LEN) >> TXHDR_LEN_SHIFT) -
@@ -3282,8 +3282,8 @@ static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 	stat = nr64(RX_DMA_CTL_STAT(rp->rx_channel));
 	qlen = nr64(RCRSTAT_A(rp->rx_channel)) & RCRSTAT_A_QLEN;
 #else
-	stat = le64_to_cpup(&mbox->rx_dma_ctl_stat);
-	qlen = (le64_to_cpup(&mbox->rcrstat_a) & RCRSTAT_A_QLEN);
+	stat = get_le64(&mbox->rx_dma_ctl_stat);
+	qlen = get_le64(&mbox->rcrstat_a) & RCRSTAT_A_QLEN;
 #endif
 	mbox->rx_dma_ctl_stat = 0;
 	mbox->rcrstat_a = 0;
@@ -3722,7 +3722,7 @@ static void niu_rxchan_intr(struct niu *np, struct rx_ring_info *rp,
 			    int ldn)
 {
 	struct rxdma_mailbox *mbox = rp->mbox;
-	u64 stat_write, stat = le64_to_cpup(&mbox->rx_dma_ctl_stat);
+	u64 stat_write, stat = get_le64(&mbox->rx_dma_ctl_stat);
 
 	stat_write = (RX_DMA_CTL_STAT_RCRTHRES |
 		      RX_DMA_CTL_STAT_RCRTO);
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 8db342f..4f54ace 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -518,7 +518,7 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 	optr = ptr = skb->data;
 
 	/* Get L2TP header flags */
-	hdrflags = ntohs(*(__be16*)ptr);
+	hdrflags = get_be16((__be16 *)ptr);
 
 	/* Trace packet contents, if enabled */
 	if (tunnel->debug & PPPOL2TP_MSG_DATA) {
@@ -554,9 +554,9 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 		ptr += 2;
 
 	/* Extract tunnel and session ID */
-	tunnel_id = ntohs(*(__be16 *) ptr);
+	tunnel_id = get_be16((__be16 *)ptr);
 	ptr += 2;
-	session_id = ntohs(*(__be16 *) ptr);
+	session_id = get_be16((__be16 *)ptr);
 	ptr += 2;
 
 	/* Find the session context */
@@ -582,9 +582,9 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 	 */
 	if (hdrflags & L2TP_HDRFLAG_S) {
 		u16 ns, nr;
-		ns = ntohs(*(__be16 *) ptr);
+		ns = get_be16((__be16 *)ptr);
 		ptr += 2;
-		nr = ntohs(*(__be16 *) ptr);
+		nr = get_be16((__be16 *)ptr);
 		ptr += 2;
 
 		/* Received a packet with sequence numbers. If we're the LNS,
@@ -642,7 +642,7 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 
 	/* If offset bit set, skip it. */
 	if (hdrflags & L2TP_HDRFLAG_O) {
-		offset = ntohs(*(__be16 *)ptr);
+		offset = get_be16((__be16 *)ptr);
 		ptr += 2 + offset;
 	}
 
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 3dd8f13..f14ddb7 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -544,10 +544,10 @@ static int __devinit rr_init(struct net_device *dev)
 	 * other method I've seen.  -VAL
 	 */
 
-	*(__be16 *)(dev->dev_addr) =
-	  htons(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA)));
-	*(__be32 *)(dev->dev_addr+2) =
-	  htonl(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA[4])));
+	put_be16(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA)),
+		 (__be16 *)(dev->dev_addr));
+	put_be32(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA[4])),
+		 (__be32 *)(dev->dev_addr + 2));
 
 	printk("  MAC: %s\n", print_mac(mac, dev->dev_addr));
 
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index b4b6380..dcf2126 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -771,7 +771,7 @@ static void _sc92031_rx_tasklet(struct net_device *dev)
 		unsigned rx_size, rx_size_align, pkt_size;
 		struct sk_buff *skb;
 
-		rx_status = le32_to_cpup((__le32 *)(rx_ring + rx_ring_offset));
+		rx_status = get_le32((__le32 *)(rx_ring + rx_ring_offset));
 		rmb();
 
 		rx_size = rx_status >> 20;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b4e7f30..77631db 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -237,7 +237,7 @@ static void pci_hme_write_txd(struct happy_meal_txd *txd, u32 flags, u32 addr)
 
 static u32 pci_hme_read_desc32(hme32 *p)
 {
-	return le32_to_cpup((__le32 *)p);
+	return get_le32((__le32 *)p);
 }
 
 #define hme_write32(__hp, __reg, __val) \
@@ -302,7 +302,7 @@ do {	(__txd)->tx_addr = (__force hme32)cpu_to_le32(__addr); \
 } while(0)
 static inline u32 hme_read_desc32(struct happy_meal *hp, hme32 *p)
 {
-	return le32_to_cpup((__le32 *)p);
+	return get_le32((__le32 *)p);
 }
 #define hme_dma_map(__hp, __ptr, __size, __dir) \
 	pci_map_single((__hp)->happy_dev, (__ptr), (__size), (__dir))
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 6562004..db3d48b 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1909,7 +1909,7 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
 	if ( ( (int) srom[18] & 0xff) == SROM_V41_CODE) {
 		/* SROM V4.01 */
 		/* Get NIC support media mode */
-		db->NIC_capability = le16_to_cpup((__le16 *) (srom + 34));
+		db->NIC_capability = get_le16((__le16 *)(srom + 34));
 		db->PHY_reg4 = 0;
 		for (tmp_reg = 1; tmp_reg < 0x10; tmp_reg <<= 1) {
 			switch( db->NIC_capability & tmp_reg ) {
@@ -1921,8 +1921,8 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
 		}
 
 		/* Media Mode Force or not check */
-		dmfe_mode = (le32_to_cpup((__le32 *) (srom + 34)) &
-			     le32_to_cpup((__le32 *) (srom + 36)));
+		dmfe_mode = (get_le32((__le32 *)(srom + 34)) &
+			     get_le32((__le32 *)(srom + 36)));
 		switch(dmfe_mode) {
 		case 0x4: dmfe_media_mode = DMFE_100MHF; break;	/* 100MHF */
 		case 0x2: dmfe_media_mode = DMFE_10MFD; break;	/* 10MFD */
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0ce07a3..bf742fb 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -552,7 +552,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		/* Be promiscuous by default to maintain previous behaviour. */
 		tun->if_flags = IFF_PROMISC;
 		/* Generate random Ethernet address. */
-		*(__be16 *)tun->dev_addr = htons(0x00FF);
+		put_be16(0x00FF, (__be16 *)tun->dev_addr);
 		get_random_bytes(tun->dev_addr + sizeof(u16), 4);
 		memset(tun->chr_filter, 0, sizeof tun->chr_filter);
 
-- 
1.5.6.rc0.277.g804cf


