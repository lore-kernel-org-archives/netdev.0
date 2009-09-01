From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/19] tokenring: convert to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:46 -0700
Message-ID: <20090901055129.095068612@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57444 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309AbZIAF6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:51 -0400
Content-Disposition: inline; filename=tokenring-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/tokenring/3c359.c       |    4 ++--
 drivers/net/tokenring/ibmtr.c       |    6 ++++--
 drivers/net/tokenring/lanstreamer.c |    6 ++++--
 drivers/net/tokenring/olympic.c     |    6 ++++--
 drivers/net/tokenring/smctr.c       |    6 ++++--
 drivers/net/tokenring/tms380tr.c    |   19 +++++++++++--------
 6 files changed, 29 insertions(+), 18 deletions(-)

--- a/drivers/net/tokenring/3c359.c	2009-08-31 16:17:53.201090186 -0700
+++ b/drivers/net/tokenring/3c359.c	2009-08-31 16:26:58.753608726 -0700
@@ -128,7 +128,7 @@ static int xl_init(struct net_device *de
 static int xl_open(struct net_device *dev);
 static int xl_open_hw(struct net_device *dev) ;  
 static int xl_hw_reset(struct net_device *dev); 
-static int xl_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t xl_xmit(struct sk_buff *skb, struct net_device *dev);
 static void xl_dn_comp(struct net_device *dev); 
 static int xl_close(struct net_device *dev);
 static void xl_set_rx_mode(struct net_device *dev);
@@ -1193,7 +1193,7 @@ static irqreturn_t xl_interrupt(int irq,
  *	Tx - Polling configuration
  */
 	
-static int xl_xmit(struct sk_buff *skb, struct net_device *dev) 
+static netdev_tx_t xl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xl_private *xl_priv=netdev_priv(dev);
 	struct xl_tx_desc *txd ; 
--- a/drivers/net/tokenring/ibmtr.c	2009-08-31 16:17:53.191088706 -0700
+++ b/drivers/net/tokenring/ibmtr.c	2009-08-31 16:26:58.753608726 -0700
@@ -191,7 +191,8 @@ static int 	tok_init_card(struct net_dev
 static void	tok_open_adapter(unsigned long dev_addr);
 static void 	open_sap(unsigned char type, struct net_device *dev);
 static void 	tok_set_multicast_list(struct net_device *dev);
-static int 	tok_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t tok_send_packet(struct sk_buff *skb,
+					 struct net_device *dev);
 static int 	tok_close(struct net_device *dev);
 static irqreturn_t tok_interrupt(int irq, void *dev_id);
 static void 	initial_tok_int(struct net_device *dev);
@@ -1022,7 +1023,8 @@ static void tok_set_multicast_list(struc
 
 #define STATION_ID_OFST 4
 
-static int tok_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t tok_send_packet(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct tok_info *ti;
 	unsigned long flags;
--- a/drivers/net/tokenring/lanstreamer.c	2009-08-31 16:17:53.181109436 -0700
+++ b/drivers/net/tokenring/lanstreamer.c	2009-08-31 16:26:58.753608726 -0700
@@ -203,7 +203,8 @@ static int streamer_ioctl(struct net_dev
 
 static int streamer_reset(struct net_device *dev);
 static int streamer_open(struct net_device *dev);
-static int streamer_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t streamer_xmit(struct sk_buff *skb,
+				       struct net_device *dev);
 static int streamer_close(struct net_device *dev);
 static void streamer_set_rx_mode(struct net_device *dev);
 static irqreturn_t streamer_interrupt(int irq, void *dev_id);
@@ -1141,7 +1142,8 @@ static irqreturn_t streamer_interrupt(in
 	return IRQ_HANDLED;
 }
 
-static int streamer_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t streamer_xmit(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
 	    netdev_priv(dev);
--- a/drivers/net/tokenring/olympic.c	2009-08-31 16:17:53.191088706 -0700
+++ b/drivers/net/tokenring/olympic.c	2009-08-31 16:26:58.753608726 -0700
@@ -182,7 +182,8 @@ MODULE_DEVICE_TABLE(pci,olympic_pci_tbl)
 static int olympic_probe(struct pci_dev *pdev, const struct pci_device_id *ent); 
 static int olympic_init(struct net_device *dev);
 static int olympic_open(struct net_device *dev);
-static int olympic_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t olympic_xmit(struct sk_buff *skb,
+				      struct net_device *dev);
 static int olympic_close(struct net_device *dev);
 static void olympic_set_rx_mode(struct net_device *dev);
 static void olympic_freemem(struct net_device *dev) ;  
@@ -1030,7 +1031,8 @@ static irqreturn_t olympic_interrupt(int
 	return IRQ_HANDLED;
 }	
 
-static int olympic_xmit(struct sk_buff *skb, struct net_device *dev) 
+static netdev_tx_t olympic_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio;
--- a/drivers/net/tokenring/smctr.c	2009-08-31 16:17:53.171107816 -0700
+++ b/drivers/net/tokenring/smctr.c	2009-08-31 16:26:58.753608726 -0700
@@ -234,7 +234,8 @@ static int smctr_rx_frame(struct net_dev
 
 /* S */
 static int smctr_send_dat(struct net_device *dev);
-static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t smctr_send_packet(struct sk_buff *skb,
+					   struct net_device *dev);
 static int smctr_send_lobe_media_test(struct net_device *dev);
 static int smctr_send_rpt_addr(struct net_device *dev, MAC_HEADER *rmf,
         __u16 correlator);
@@ -4571,7 +4572,8 @@ static void smctr_timeout(struct net_dev
 /*
  * Gets skb from system, queues it and checks if it can be sent
  */
-static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t smctr_send_packet(struct sk_buff *skb,
+					   struct net_device *dev)
 {
         struct net_local *tp = netdev_priv(dev);
 
--- a/drivers/net/tokenring/tms380tr.c	2009-08-31 16:17:53.161108571 -0700
+++ b/drivers/net/tokenring/tms380tr.c	2009-08-31 16:26:58.753608726 -0700
@@ -144,8 +144,8 @@ static void 	tms380tr_exec_sifcmd(struct
 /* "G" */
 static struct net_device_stats *tms380tr_get_stats(struct net_device *dev);
 /* "H" */
-static int 	tms380tr_hardware_send_packet(struct sk_buff *skb,
-			struct net_device *dev);
+static netdev_tx_t tms380tr_hardware_send_packet(struct sk_buff *skb,
+						       struct net_device *dev);
 /* "I" */
 static int 	tms380tr_init_adapter(struct net_device *dev);
 static void 	tms380tr_init_ipb(struct net_local *tp);
@@ -165,7 +165,8 @@ static int 	tms380tr_reset_adapter(struc
 static void 	tms380tr_reset_interrupt(struct net_device *dev);
 static void 	tms380tr_ring_status_irq(struct net_device *dev);
 /* "S" */
-static int 	tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t tms380tr_send_packet(struct sk_buff *skb,
+					      struct net_device *dev);
 static void 	tms380tr_set_multicast_list(struct net_device *dev);
 static int	tms380tr_set_mac_address(struct net_device *dev, void *addr);
 /* "T" */
@@ -599,21 +600,23 @@ static void tms380tr_timeout(struct net_
 /*
  * Gets skb from system, queues it and checks if it can be sent
  */
-static int tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t tms380tr_send_packet(struct sk_buff *skb,
+					      struct net_device *dev)
 {
 	struct net_local *tp = netdev_priv(dev);
-	int err;
+	netdev_tx_t rc;
 
-	err = tms380tr_hardware_send_packet(skb, dev);
+	rc = tms380tr_hardware_send_packet(skb, dev);
 	if(tp->TplFree->NextTPLPtr->BusyFlag)
 		netif_stop_queue(dev);
-	return (err);
+	return rc;
 }
 
 /*
  * Move frames into adapter tx queue
  */
-static int tms380tr_hardware_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t tms380tr_hardware_send_packet(struct sk_buff *skb,
+						       struct net_device *dev)
 {
 	TPL *tpl;
 	short length;

-- 

