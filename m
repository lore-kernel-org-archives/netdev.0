From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] drivers/net: replace BUG() with BUG_ON() if possible
Date: Sun, 12 Apr 2009 04:50:23 +0400
Message-ID: <20090412005023.GA20388@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:57163 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbZDLAue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 20:50:34 -0400
Received: by fg-out-1718.google.com with SMTP id 16so205799fgg.17
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 17:50:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/atl1e/atl1e_main.c            |    3 +--
 drivers/net/atlx/atl1.c                   |    7 +++----
 drivers/net/chelsio/sge.c                 |    4 ++--
 drivers/net/fs_enet/mii-fec.c             |    6 ++----
 drivers/net/ixgb/ixgb_osdep.h             |    2 +-
 drivers/net/pppol2tp.c                    |    3 +--
 drivers/net/tulip/winbond-840.c           |    3 +--
 drivers/net/virtio_net.c                  |   12 ++++--------
 drivers/net/wireless/ath5k/reset.c        |    5 ++---
 drivers/net/wireless/ath9k/ath9k.h        |    6 +-----
 drivers/net/wireless/ipw2x00/ipw2200.c    |    7 ++-----
 drivers/net/wireless/libertas/if_usb.c    |    3 +--
 drivers/net/wireless/libertas_tf/if_usb.c |    3 +--
 13 files changed, 22 insertions(+), 42 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index fb57b75..adac061 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1794,8 +1794,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 			memcpy(use_tpd, tpd, sizeof(struct atl1e_tpd_desc));
 
 			tx_buffer = atl1e_get_tx_buffer(adapter, use_tpd);
-			if (tx_buffer->skb)
-				BUG();
+			BUG_ON(tx_buffer->skb);
 
 			tx_buffer->skb = NULL;
 			tx_buffer->length =
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 0ab2254..13f0bdc 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2207,8 +2207,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	next_to_use = atomic_read(&tpd_ring->next_to_use);
 	buffer_info = &tpd_ring->buffer_info[next_to_use];
-	if (unlikely(buffer_info->skb))
-		BUG();
+	BUG_ON(buffer_info->skb);
 	/* put skb in last TPD */
 	buffer_info->skb = NULL;
 
@@ -2274,8 +2273,8 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 			ATL1_MAX_TX_BUF_LEN;
 		for (i = 0; i < nseg; i++) {
 			buffer_info = &tpd_ring->buffer_info[next_to_use];
-			if (unlikely(buffer_info->skb))
-				BUG();
+			BUG_ON(buffer_info->skb);
+
 			buffer_info->skb = NULL;
 			buffer_info->length = (buf_len > ATL1_MAX_TX_BUF_LEN) ?
 				ATL1_MAX_TX_BUF_LEN : buf_len;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 58f6fc0..5e97a1a 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1149,8 +1149,8 @@ static inline void write_tx_desc(struct cmdQ_e *e, dma_addr_t mapping,
 				 unsigned int len, unsigned int gen,
 				 unsigned int eop)
 {
-	if (unlikely(len > SGE_TX_DESC_MAX_PLEN))
-		BUG();
+	BUG_ON(len > SGE_TX_DESC_MAX_PLEN);
+
 	e->addr_lo = (u32)mapping;
 	e->addr_hi = (u64)mapping >> 32;
 	e->len_gen = V_CMD_LEN(len) | V_CMD_GEN1(gen);
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 28077cc..61aaae4 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -54,8 +54,7 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 	fec_t __iomem *fecp = fec->fecp;
 	int i, ret = -1;
 
-	if ((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0)
-		BUG();
+	BUG_ON((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
 
 	/* Add PHY address to register command.  */
 	out_be32(&fecp->fec_mii_data, (phy_id << 23) | mk_mii_read(location));
@@ -79,8 +78,7 @@ static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location,
 	int i;
 
 	/* this must never happen */
-	if ((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0)
-		BUG();
+	BUG_ON((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
 
 	/* Add PHY address to register command.  */
 	out_be32(&fecp->fec_mii_data, (phy_id << 23) | mk_mii_write(location, val));
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index d92e72b..371a6be 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -40,7 +40,7 @@
 #include <linux/sched.h>
 
 #undef ASSERT
-#define ASSERT(x)	if (!(x)) BUG()
+#define ASSERT(x)	BUG_ON(!(x))
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
 
 #ifdef DBG
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 5b07dd8..5981deb 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1238,8 +1238,7 @@ static void pppol2tp_tunnel_closeall(struct pppol2tp_tunnel *tunnel)
 	struct pppol2tp_session *session;
 	struct sock *sk;
 
-	if (tunnel == NULL)
-		BUG();
+	BUG_ON(tunnel == NULL);
 
 	PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
 	       "%s: closing all sessions...\n", tunnel->name);
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 264e614..842b1a2 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1601,8 +1601,7 @@ static int w840_suspend (struct pci_dev *pdev, pm_message_t state)
 
 		/* no more hardware accesses behind this line. */
 
-		BUG_ON(np->csr6);
-		if (ioread32(ioaddr + IntrEnable)) BUG();
+		BUG_ON(np->csr6 || ioread32(ioaddr + IntrEnable));
 
 		/* pci_power_off(pdev, -1); */
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9c82a39..0718558 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -621,12 +621,9 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 	virtio_net_ctrl_ack status = ~0;
 	unsigned int tmp;
 
-	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
-		BUG();  /* Caller should know better */
-		return false;
-	}
-
-	BUG_ON(out + in > VIRTNET_SEND_COMMAND_SG_MAX);
+	/* Caller should know better */
+	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ||
+		(out + in > VIRTNET_SEND_COMMAND_SG_MAX));
 
 	out++; /* Add header */
 	in++; /* Add return status */
@@ -640,8 +637,7 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 	memcpy(&sg[1], data, sizeof(struct scatterlist) * (out + in - 2));
 	sg_set_buf(&sg[out + in - 1], &status, sizeof(status));
 
-	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, out, in, vi) != 0)
-		BUG();
+	BUG_ON(vi->cvq->vq_ops->add_buf(vi->cvq, sg, out, in, vi));
 
 	vi->cvq->vq_ops->kick(vi->cvq);
 
diff --git a/drivers/net/wireless/ath5k/reset.c b/drivers/net/wireless/ath5k/reset.c
index 7a17d31..cb5e15f 100644
--- a/drivers/net/wireless/ath5k/reset.c
+++ b/drivers/net/wireless/ath5k/reset.c
@@ -54,9 +54,8 @@ static inline int ath5k_hw_write_ofdm_timings(struct ath5k_hw *ah,
 	u32 coef_scaled, coef_exp, coef_man,
 		ds_coef_exp, ds_coef_man, clock;
 
-	if (!(ah->ah_version == AR5K_AR5212) ||
-		!(channel->hw_value & CHANNEL_OFDM))
-		BUG();
+	BUG_ON(!(ah->ah_version == AR5K_AR5212) ||
+		!(channel->hw_value & CHANNEL_OFDM));
 
 	/* Get coefficient
 	 * ALGO: coef = (5 * clock * carrier_freq) / 2)
diff --git a/drivers/net/wireless/ath9k/ath9k.h b/drivers/net/wireless/ath9k/ath9k.h
index 2689a08..7b1b40a 100644
--- a/drivers/net/wireless/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath9k/ath9k.h
@@ -53,11 +53,7 @@ struct ath_node;
 
 #define A_MAX(a, b) ((a) > (b) ? (a) : (b))
 
-#define ASSERT(exp) do {			\
-		if (unlikely(!(exp))) {		\
-			BUG();			\
-		}				\
-	} while (0)
+#define ASSERT(exp) BUG_ON(!(exp))
 
 #define TSF_TO_TU(_h,_l) \
 	((((u32)(_h)) << 22) | (((u32)(_l)) >> 10))
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index bd4dbcf..9a123fb 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -3176,11 +3176,8 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 	/* Start the Dma */
 	rc = ipw_fw_dma_enable(priv);
 
-	if (priv->sram_desc.last_cb_index > 0) {
-		/* the DMA is already ready this would be a bug. */
-		BUG();
-		goto out;
-	}
+	/* the DMA is already ready this would be a bug. */
+	BUG_ON(priv->sram_desc.last_cb_index > 0);
 
 	do {
 		chunk = (struct fw_chunk *)(data + offset);
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index ea3dc03..d649cae 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -686,8 +686,7 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 		return;
 	}
 
-	if (!in_interrupt())
-		BUG();
+	BUG_ON(!in_interrupt());
 
 	spin_lock(&priv->driver_lock);
 
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index 59634c3..392337b 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -461,8 +461,7 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 		return;
 	}
 
-	if (!in_interrupt())
-		BUG();
+	BUG_ON(!in_interrupt());
 
 	spin_lock(&priv->driver_lock);
 	memcpy(priv->cmd_resp_buff, recvbuff + MESSAGE_HEADER_LEN,
