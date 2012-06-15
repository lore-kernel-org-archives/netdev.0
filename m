From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 16/20] ray_cs: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:56 -0700
Message-ID: <5dd6a13d41f62be30a344aa690cc5ad8ee8956d9.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ray_cs.c |  147 +++++++++++++++++++----------------------
 1 files changed, 69 insertions(+), 78 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 86a738b..fc8c59a 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -30,6 +30,8 @@
  *
 =============================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/proc_fs.h>
@@ -364,11 +366,11 @@ static int ray_config(struct pcmcia_device *link)
 	dev_dbg(&link->dev, "ray_config\n");
 
 	/* Determine card type and firmware version */
-	printk(KERN_INFO "ray_cs Detected: %s%s%s%s\n",
-	       link->prod_id[0] ? link->prod_id[0] : " ",
-	       link->prod_id[1] ? link->prod_id[1] : " ",
-	       link->prod_id[2] ? link->prod_id[2] : " ",
-	       link->prod_id[3] ? link->prod_id[3] : " ");
+	pr_info("Detected: %s%s%s%s\n",
+		link->prod_id[0] ? link->prod_id[0] : " ",
+		link->prod_id[1] ? link->prod_id[1] : " ",
+		link->prod_id[2] ? link->prod_id[2] : " ",
+		link->prod_id[3] ? link->prod_id[3] : " ");
 
 	/* Now allocate an interrupt line.  Note that this does not
 	   actually assign a handler to the interrupt.
@@ -439,8 +441,8 @@ static int ray_config(struct pcmcia_device *link)
 		return i;
 	}
 
-	printk(KERN_INFO "%s: RayLink, irq %d, hw_addr %pM\n",
-	       dev->name, dev->irq, dev->dev_addr);
+	pr_info("%s: RayLink, irq %d, hw_addr %pM\n",
+		dev->name, dev->irq, dev->dev_addr);
 
 	return 0;
 
@@ -489,8 +491,8 @@ static int ray_init(struct net_device *dev)
 
 	/* Check Power up test status and get mac address from card */
 	if (local->startup_res.startup_word != 0x80) {
-		printk(KERN_INFO "ray_init ERROR card status = %2x\n",
-		       local->startup_res.startup_word);
+		pr_info("%s: ERROR card status = %2x\n",
+			__func__, local->startup_res.startup_word);
 		local->card_status = CARD_INIT_ERROR;
 		return -1;
 	}
@@ -560,8 +562,7 @@ static int dl_startup_params(struct net_device *dev)
 	      local->dl_param_ccs);
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		printk(KERN_INFO "ray dl_startup_params failed - "
-		       "ECF not ready for intr\n");
+		pr_info("%s: failed - ECF not ready for intr\n", __func__);
 		local->card_status = CARD_DL_PARAM_ERROR;
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 		return -2;
@@ -668,9 +669,8 @@ static void verify_dl_startup(u_long data)
 
 	status = readb(&pccs->buffer_status);
 	if (status != CCS_BUFFER_FREE) {
-		printk(KERN_INFO
-		       "Download startup params failed.  Status = %d\n",
-		       status);
+		pr_info("Download startup params failed.  Status = %d\n",
+			status);
 		local->card_status = CARD_DL_PARAM_ERROR;
 		return;
 	}
@@ -794,8 +794,8 @@ static int ray_dev_init(struct net_device *dev)
 #ifdef RAY_IMMEDIATE_INIT
 	/* Download startup parameters */
 	if ((i = dl_startup_params(dev)) < 0) {
-		printk(KERN_INFO "ray_dev_init dl_startup_params failed - "
-		       "returns 0x%x\n", i);
+		pr_info("%s: dl_startup_params failed - returns 0x%x\n",
+			__func__, i);
 		return -1;
 	}
 #else /* RAY_IMMEDIATE_INIT */
@@ -885,17 +885,17 @@ static int ray_hw_xmit(unsigned char *data, int len, struct net_device *dev,
 	struct tx_msg __iomem *ptx;	/* Address of xmit buffer in PC space */
 	short int addr;		/* Address of xmit buffer in card space */
 
-	pr_debug("ray_hw_xmit(data=%p, len=%d, dev=%p)\n", data, len, dev);
+	pr_debug("%s: (data=%p, len=%d, dev=%p)\n", __func__, data, len, dev);
 	if (len + TX_HEADER_LENGTH > TX_BUF_SIZE) {
-		printk(KERN_INFO "ray_hw_xmit packet too large: %d bytes\n",
+		pr_info("ray_hw_xmit packet too large: %d bytes\n",
 		       len);
 		return XMIT_MSG_BAD;
 	}
 	switch (ccsindex = get_free_tx_ccs(local)) {
 	case ECCSBUSY:
-		pr_debug("ray_hw_xmit tx_ccs table busy\n");
+		pr_debug("%s: tx_ccs table busy\n", __func__);
 	case ECCSFULL:
-		pr_debug("ray_hw_xmit No free tx ccs\n");
+		pr_debug("%s: No free tx ccs\n", __func__);
 	case ECARDGONE:
 		netif_stop_queue(dev);
 		return XMIT_NO_CCS;
@@ -932,12 +932,12 @@ static int ray_hw_xmit(unsigned char *data, int len, struct net_device *dev,
 	writeb(PSM_CAM, &pccs->var.tx_request.pow_sav_mode);
 	writeb(local->net_default_tx_rate, &pccs->var.tx_request.tx_rate);
 	writeb(0, &pccs->var.tx_request.antenna);
-	pr_debug("ray_hw_xmit default_tx_rate = 0x%x\n",
-	      local->net_default_tx_rate);
+	pr_debug("%s: default_tx_rate = 0x%x\n",
+		 __func__, local->net_default_tx_rate);
 
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		pr_debug("ray_hw_xmit failed - ECF not ready for intr\n");
+		pr_debug("%s: failed - ECF not ready for intr\n", __func__);
 /* TBD very inefficient to copy packet to buffer, and then not
    send it, but the alternative is to queue the messages and that
    won't be done for a while.  Maybe set tbusy until a CCS is free?
@@ -954,7 +954,7 @@ static int translate_frame(ray_dev_t *local, struct tx_msg __iomem *ptx,
 {
 	__be16 proto = ((struct ethhdr *)data)->h_proto;
 	if (ntohs(proto) >= 1536) { /* DIX II ethernet frame */
-		pr_debug("ray_cs translate_frame DIX II\n");
+		pr_debug("%s: DIX II\n", __func__);
 		/* Copy LLC header to card buffer */
 		memcpy_toio(&ptx->var, eth2_llc, sizeof(eth2_llc));
 		memcpy_toio(((void __iomem *)&ptx->var) + sizeof(eth2_llc),
@@ -970,9 +970,9 @@ static int translate_frame(ray_dev_t *local, struct tx_msg __iomem *ptx,
 			    len - ETH_HLEN);
 		return (int)sizeof(struct snaphdr_t) - ETH_HLEN;
 	} else { /* already  802 type, and proto is length */
-		pr_debug("ray_cs translate_frame 802\n");
+		pr_debug("%s: 802\n", __func__);
 		if (proto == htons(0xffff)) { /* evil netware IPX 802.3 without LLC */
-			pr_debug("ray_cs translate_frame evil IPX\n");
+			pr_debug("%s: evil IPX\n", __func__);
 			memcpy_toio(&ptx->var, data + ETH_HLEN, len - ETH_HLEN);
 			return 0 - ETH_HLEN;
 		}
@@ -1501,9 +1501,8 @@ static int ray_open(struct net_device *dev)
 
 		/* Download startup parameters */
 		if ((i = dl_startup_params(dev)) < 0) {
-			printk(KERN_INFO
-			       "ray_dev_init dl_startup_params failed - "
-			       "returns 0x%x\n", i);
+			pr_info("ray_dev_init dl_startup_params failed - returns 0x%x\n",
+				i);
 			return -1;
 		}
 	}
@@ -1540,7 +1539,7 @@ static int ray_dev_close(struct net_device *dev)
 /*===========================================================================*/
 static void ray_reset(struct net_device *dev)
 {
-	pr_debug("ray_reset entered\n");
+	pr_debug("%s: entered\n", __func__);
 }
 
 /*===========================================================================*/
@@ -1639,8 +1638,7 @@ static void authenticate_timeout(u_long data)
 {
 	ray_dev_t *local = (ray_dev_t *) data;
 	del_timer(&local->timer);
-	printk(KERN_INFO "ray_cs Authentication with access point failed"
-	       " - timeout\n");
+	pr_info("Authentication with access point failed - timeout\n");
 	join_net((u_long) local);
 }
 
@@ -1800,11 +1798,11 @@ static void set_multicast_list(struct net_device *dev)
 	ray_dev_t *local = netdev_priv(dev);
 	UCHAR promisc;
 
-	pr_debug("ray_cs set_multicast_list(%p)\n", dev);
+	pr_debug("%s: (%p)\n", __func__, dev);
 
 	if (dev->flags & IFF_PROMISC) {
 		if (local->sparm.b5.a_promiscuous_mode == 0) {
-			pr_debug("ray_cs set_multicast_list promisc on\n");
+			pr_debug("%s: promisc on\n", __func__);
 			local->sparm.b5.a_promiscuous_mode = 1;
 			promisc = 1;
 			ray_update_parm(dev, OBJID_promiscuous_mode,
@@ -1812,7 +1810,7 @@ static void set_multicast_list(struct net_device *dev)
 		}
 	} else {
 		if (local->sparm.b5.a_promiscuous_mode == 1) {
-			pr_debug("ray_cs set_multicast_list promisc off\n");
+			pr_debug("%s: promisc off\n", __func__);
 			local->sparm.b5.a_promiscuous_mode = 0;
 			promisc = 0;
 			ray_update_parm(dev, OBJID_promiscuous_mode,
@@ -1846,13 +1844,12 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 	if (dev == NULL)	/* Note that we want interrupts with dev->start == 0 */
 		return IRQ_NONE;
 
-	pr_debug("ray_cs: interrupt for *dev=%p\n", dev);
+	pr_debug("interrupt for *dev=%p\n", dev);
 
 	local = netdev_priv(dev);
 	link = (struct pcmcia_device *)local->finder;
 	if (!pcmcia_dev_present(link)) {
-		pr_debug(
-			"ray_cs interrupt from device not present or suspended.\n");
+		pr_debug("interrupt from device not present or suspended\n");
 		return IRQ_NONE;
 	}
 	rcsindex = readb(&((struct scb __iomem *)(local->sram))->rcs_index);
@@ -2045,7 +2042,7 @@ static void ray_rx(struct net_device *dev, ray_dev_t *local,
 	int rx_len;
 	unsigned int pkt_addr;
 	void __iomem *pmsg;
-	pr_debug("ray_rx process rx packet\n");
+	pr_debug("%s: process rx packet\n", __func__);
 
 	/* Calculate address of packet within Rx buffer */
 	pkt_addr = ((readb(&prcs->var.rx_packet.rx_data_ptr[0]) << 8)
@@ -2058,28 +2055,28 @@ static void ray_rx(struct net_device *dev, ray_dev_t *local,
 	pmsg = local->rmem + pkt_addr;
 	switch (readb(pmsg)) {
 	case DATA_TYPE:
-		pr_debug("ray_rx data type\n");
+		pr_debug("%s: data type\n", __func__);
 		rx_data(dev, prcs, pkt_addr, rx_len);
 		break;
 	case AUTHENTIC_TYPE:
-		pr_debug("ray_rx authentic type\n");
+		pr_debug("%s: authentic type\n", __func__);
 		if (sniffer)
 			rx_data(dev, prcs, pkt_addr, rx_len);
 		else
 			rx_authenticate(local, prcs, pkt_addr, rx_len);
 		break;
 	case DEAUTHENTIC_TYPE:
-		pr_debug("ray_rx deauth type\n");
+		pr_debug("%s: deauth type\n", __func__);
 		if (sniffer)
 			rx_data(dev, prcs, pkt_addr, rx_len);
 		else
 			rx_deauthenticate(local, prcs, pkt_addr, rx_len);
 		break;
 	case NULL_MSG_TYPE:
-		pr_debug("ray_cs rx NULL msg\n");
+		pr_debug("%s: rx NULL msg\n", __func__);
 		break;
 	case BEACON_TYPE:
-		pr_debug("ray_rx beacon type\n");
+		pr_debug("%s: beacon type\n", __func__);
 		if (sniffer)
 			rx_data(dev, prcs, pkt_addr, rx_len);
 
@@ -2092,8 +2089,8 @@ static void ray_rx(struct net_device *dev, ray_dev_t *local,
 		ray_get_stats(dev);
 		break;
 	default:
-		pr_debug("ray_cs unknown pkt type %2x\n",
-		      (unsigned int)readb(pmsg));
+		pr_debug("%s: unknown pkt type %2x\n",
+			 __func__, (unsigned int)readb(pmsg));
 		break;
 	}
 
@@ -2121,9 +2118,8 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 			    rx_len >
 			    (dev->mtu + RX_MAC_HEADER_LENGTH + ETH_HLEN +
 			     FCS_LEN)) {
-				pr_debug(
-				      "ray_cs invalid packet length %d received\n",
-				      rx_len);
+				pr_debug("invalid packet length %d received\n",
+					 rx_len);
 				return;
 			}
 		} else { /* encapsulated ethernet */
@@ -2132,17 +2128,16 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 			    rx_len >
 			    (dev->mtu + RX_MAC_HEADER_LENGTH + ETH_HLEN +
 			     FCS_LEN)) {
-				pr_debug(
-				      "ray_cs invalid packet length %d received\n",
-				      rx_len);
+				pr_debug("invalid packet length %d received\n",
+					 rx_len);
 				return;
 			}
 		}
 	}
-	pr_debug("ray_cs rx_data packet\n");
+	pr_debug("rx_data packet\n");
 	/* If fragmented packet, verify sizes of fragments add up */
 	if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF) {
-		pr_debug("ray_cs rx'ed fragment\n");
+		pr_debug("rx'ed fragment\n");
 		tmp = (readb(&prcs->var.rx_packet.totalpacketlength[0]) << 8)
 		    + readb(&prcs->var.rx_packet.totalpacketlength[1]);
 		total_len = tmp;
@@ -2160,8 +2155,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 		} while (1);
 
 		if (tmp < 0) {
-			pr_debug(
-			      "ray_cs rx_data fragment lengths don't add up\n");
+			pr_debug("rx_data fragment lengths don't add up\n");
 			local->stats.rx_dropped++;
 			release_frag_chain(local, prcs);
 			return;
@@ -2172,7 +2166,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 
 	skb = dev_alloc_skb(total_len + 5);
 	if (skb == NULL) {
-		pr_debug("ray_cs rx_data could not allocate skb\n");
+		pr_debug("rx_data could not allocate skb\n");
 		local->stats.rx_dropped++;
 		if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF)
 			release_frag_chain(local, prcs);
@@ -2180,8 +2174,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 	}
 	skb_reserve(skb, 2);	/* Align IP on 16 byte (TBD check this) */
 
-	pr_debug("ray_cs rx_data total_len = %x, rx_len = %x\n", total_len,
-	      rx_len);
+	pr_debug("rx_data total_len = %x, rx_len = %x\n", total_len, rx_len);
 
 /************************/
 	/* Reserve enough room for the whole damn packet. */
@@ -2213,7 +2206,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 	tmp = 17;
 	if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF) {
 		prcslink = prcs;
-		pr_debug("ray_cs rx_data in fragment loop\n");
+		pr_debug("rx_data in fragment loop\n");
 		do {
 			prcslink = rcs_base(local)
 			    +
@@ -2300,8 +2293,8 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 
 	if (psnap->dsap != 0xaa || psnap->ssap != 0xaa || psnap->ctrl != 3) {
 		/* not a snap type so leave it alone */
-		pr_debug("ray_cs untranslate NOT SNAP %02x %02x %02x\n",
-		      psnap->dsap, psnap->ssap, psnap->ctrl);
+		pr_debug("untranslate NOT SNAP %02x %02x %02x\n",
+			 psnap->dsap, psnap->ssap, psnap->ctrl);
 
 		delta = RX_MAC_HEADER_LENGTH - ETH_HLEN;
 		peth = (struct ethhdr *)(skb->data + delta);
@@ -2309,7 +2302,7 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 	} else { /* Its a SNAP */
 		if (memcmp(psnap->org, org_bridge, 3) == 0) {
 		/* EtherII and nuke the LLC */
-			pr_debug("ray_cs untranslate Bridge encap\n");
+			pr_debug("untranslate Bridge encap\n");
 			delta = RX_MAC_HEADER_LENGTH
 			    + sizeof(struct snaphdr_t) - ETH_HLEN;
 			peth = (struct ethhdr *)(skb->data + delta);
@@ -2318,14 +2311,14 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 			switch (ntohs(type)) {
 			case ETH_P_IPX:
 			case ETH_P_AARP:
-				pr_debug("ray_cs untranslate RFC IPX/AARP\n");
+				pr_debug("untranslate RFC IPX/AARP\n");
 				delta = RX_MAC_HEADER_LENGTH - ETH_HLEN;
 				peth = (struct ethhdr *)(skb->data + delta);
 				peth->h_proto =
 				    htons(len - RX_MAC_HEADER_LENGTH);
 				break;
 			default:
-				pr_debug("ray_cs untranslate RFC default\n");
+				pr_debug("untranslate RFC default\n");
 				delta = RX_MAC_HEADER_LENGTH +
 				    sizeof(struct snaphdr_t) - ETH_HLEN;
 				peth = (struct ethhdr *)(skb->data + delta);
@@ -2341,8 +2334,8 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 	}
 /* TBD reserve  skb_reserve(skb, delta); */
 	skb_pull(skb, delta);
-	pr_debug("untranslate after skb_pull(%d), skb->data = %p\n", delta,
-	      skb->data);
+	pr_debug("untranslate after skb_pull(%d), skb->data = %p\n",
+		 delta, skb->data);
 	memcpy(peth->h_dest, destaddr, ADDRLEN);
 	memcpy(peth->h_source, srcaddr, ADDRLEN);
 #if 0
@@ -2388,8 +2381,7 @@ static void release_frag_chain(ray_dev_t *local, struct rcs __iomem *prcs)
 	while (tmp--) {
 		writeb(CCS_BUFFER_FREE, &prcslink->buffer_status);
 		if (rcsindex >= (NUMBER_OF_CCS + NUMBER_OF_RCS)) {
-			pr_debug("ray_cs interrupt bad rcsindex = 0x%x\n",
-			      rcsindex);
+			pr_debug("interrupt bad rcsindex = 0x%x\n", rcsindex);
 			break;
 		}
 		prcslink = rcs_base(local) + rcsindex;
@@ -2432,11 +2424,11 @@ static void rx_authenticate(ray_dev_t *local, struct rcs __iomem *prcs,
 	copy_from_rx_buff(local, buff, pkt_addr, rx_len & 0xff);
 	/* if we are trying to get authenticated */
 	if (local->sparm.b4.a_network_type == ADHOC) {
-		pr_debug("ray_cs rx_auth var= %02x %02x %02x %02x %02x %02x\n",
-		      msg->var[0], msg->var[1], msg->var[2], msg->var[3],
-		      msg->var[4], msg->var[5]);
+		pr_debug("rx_auth var= %02x %02x %02x %02x %02x %02x\n",
+			 msg->var[0], msg->var[1], msg->var[2], msg->var[3],
+			 msg->var[4], msg->var[5]);
 		if (msg->var[2] == 1) {
-			pr_debug("ray_cs Sending authentication response.\n");
+			pr_debug("Sending authentication response\n");
 			if (!build_auth_frame
 			    (local, msg->mac.addr_2, OPEN_AUTH_RESPONSE)) {
 				local->authentication_state = NEED_TO_AUTH;
@@ -2682,7 +2674,7 @@ static int build_auth_frame(ray_dev_t *local, UCHAR *dest, int auth_type)
 
 	/* If no tx buffers available, return */
 	if ((ccsindex = get_free_tx_ccs(local)) < 0) {
-		pr_debug("ray_cs send authenticate - No free tx ccs\n");
+		pr_debug("send authenticate - No free tx ccs\n");
 		return -1;
 	}
 
@@ -2714,8 +2706,7 @@ static int build_auth_frame(ray_dev_t *local, UCHAR *dest, int auth_type)
 
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		pr_debug(
-		      "ray_cs send authentication request failed - ECF not ready for intr\n");
+		pr_debug("send authentication request failed - ECF not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 		return -1;
 	}
@@ -2804,7 +2795,7 @@ static int __init init_ray_cs(void)
 	pr_debug("%s\n", rcsid);
 	rc = pcmcia_register_driver(&ray_driver);
 	pr_debug("raylink init_module register_pcmcia_driver returns 0x%x\n",
-	      rc);
+		 rc);
 
 #ifdef CONFIG_PROC_FS
 	proc_mkdir("driver/ray_cs", NULL);
@@ -2823,7 +2814,7 @@ static int __init init_ray_cs(void)
 
 static void __exit exit_ray_cs(void)
 {
-	pr_debug("ray_cs: cleanup_module\n");
+	pr_debug("cleanup_module\n");
 
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("driver/ray_cs/ray_cs", NULL);
-- 
1.7.8.111.gad25c.dirty
