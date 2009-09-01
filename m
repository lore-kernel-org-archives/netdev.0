From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/19] irda: convert to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:50 -0700
Message-ID: <20090901055129.503929171@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47138 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbZIAGFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 02:05:41 -0400
Content-Disposition: inline; filename=irda-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/irda/ali-ircc.c     |   12 ++++++++----
 drivers/net/irda/donauboe.c     |    2 +-
 drivers/net/irda/irda-usb.c     |    6 ++++--
 drivers/net/irda/kingsun-sir.c  |    5 +++--
 drivers/net/irda/ks959-sir.c    |    3 ++-
 drivers/net/irda/ksdazzle-sir.c |    3 ++-
 drivers/net/irda/mcs7780.c      |    3 ++-
 drivers/net/irda/mcs7780.h      |    3 ++-
 drivers/net/irda/nsc-ircc.c     |   12 ++++++++----
 drivers/net/irda/sir_dev.c      |    3 ++-
 drivers/net/irda/smsc-ircc2.c   |   15 ++++++++++-----
 drivers/net/irda/stir4200.c     |    3 ++-
 drivers/net/irda/via-ircc.c     |   16 ++++++++--------
 drivers/net/irda/vlsi_ir.c      |    3 ++-
 drivers/net/irda/w83977af_ir.c  |    6 ++++--
 net/irda/irlan/irlan_eth.c      |    6 ++++--
 16 files changed, 64 insertions(+), 37 deletions(-)

--- a/drivers/net/irda/ali-ircc.c	2009-08-31 16:17:52.801108556 -0700
+++ b/drivers/net/irda/ali-ircc.c	2009-08-31 16:27:10.043581476 -0700
@@ -111,7 +111,8 @@ static int  ali_ircc_net_ioctl(struct ne
 static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud);
 
 /* SIR function */
-static int  ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ali_ircc_sir_hard_xmit(struct sk_buff *skb,
+						struct net_device *dev);
 static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self);
 static void ali_ircc_sir_receive(struct ali_ircc_cb *self);
 static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self);
@@ -119,7 +120,8 @@ static int  ali_ircc_sir_write(int iobas
 static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed);
 
 /* FIR function */
-static int  ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t  ali_ircc_fir_hard_xmit(struct sk_buff *skb,
+						 struct net_device *dev);
 static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 speed);
 static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self);
 static int  ali_ircc_dma_receive(struct ali_ircc_cb *self); 
@@ -1435,7 +1437,8 @@ static int ali_ircc_net_close(struct net
  *    Transmit the frame
  *
  */
-static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct ali_ircc_cb *self;
 	unsigned long flags;
@@ -1957,7 +1960,8 @@ static int  ali_ircc_dma_receive_complet
  *    Transmit the frame!
  *
  */
-static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ali_ircc_sir_hard_xmit(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct ali_ircc_cb *self;
 	unsigned long flags;
--- a/drivers/net/irda/irda-usb.c	2009-08-31 16:17:52.791092269 -0700
+++ b/drivers/net/irda/irda-usb.c	2009-08-31 16:27:10.043581476 -0700
@@ -111,7 +111,8 @@ static void irda_usb_init_qos(struct ird
 static struct irda_class_desc *irda_usb_find_class_desc(struct usb_interface *intf);
 static void irda_usb_disconnect(struct usb_interface *intf);
 static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self);
-static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
+					    struct net_device *dev);
 static int irda_usb_open(struct irda_usb_cb *self);
 static void irda_usb_close(struct irda_usb_cb *self);
 static void speed_bulk_callback(struct urb *urb);
@@ -381,7 +382,8 @@ static void speed_bulk_callback(struct u
 /*
  * Send an IrDA frame to the USB dongle (for transmission)
  */
-static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
+					    struct net_device *netdev)
 {
 	struct irda_usb_cb *self = netdev_priv(netdev);
 	struct urb *urb = self->tx_urb;
--- a/drivers/net/irda/kingsun-sir.c	2009-08-31 16:17:52.811133713 -0700
+++ b/drivers/net/irda/kingsun-sir.c	2009-08-31 16:27:10.043581476 -0700
@@ -150,7 +150,8 @@ static void kingsun_send_irq(struct urb 
 /*
  * Called from net/core when new frame is available.
  */
-static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t kingsun_hard_xmit(struct sk_buff *skb,
+					   struct net_device *netdev)
 {
 	struct kingsun_cb *kingsun;
 	int wraplen;
@@ -416,7 +417,7 @@ static int kingsun_net_ioctl(struct net_
 }
 
 static const struct net_device_ops kingsun_ops = {
-	.ndo_start_xmit = kingsun_hard_xmit,
+	.ndo_start_xmit	     = kingsun_hard_xmit,
 	.ndo_open            = kingsun_net_open,
 	.ndo_stop            = kingsun_net_close,
 	.ndo_do_ioctl        = kingsun_net_ioctl,
--- a/drivers/net/irda/ks959-sir.c	2009-08-31 16:17:52.841087172 -0700
+++ b/drivers/net/irda/ks959-sir.c	2009-08-31 16:27:10.043581476 -0700
@@ -385,7 +385,8 @@ static void ks959_send_irq(struct urb *u
 /*
  * Called from net/core when new frame is available.
  */
-static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t ks959_hard_xmit(struct sk_buff *skb,
+					 struct net_device *netdev)
 {
 	struct ks959_cb *kingsun;
 	unsigned int wraplen;
--- a/drivers/net/irda/ksdazzle-sir.c	2009-08-31 16:17:52.791092269 -0700
+++ b/drivers/net/irda/ksdazzle-sir.c	2009-08-31 16:27:10.043581476 -0700
@@ -298,7 +298,8 @@ static void ksdazzle_send_irq(struct urb
 /*
  * Called from net/core when new frame is available.
  */
-static int ksdazzle_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t ksdazzle_hard_xmit(struct sk_buff *skb,
+					    struct net_device *netdev)
 {
 	struct ksdazzle_cb *kingsun;
 	unsigned int wraplen;
--- a/drivers/net/irda/mcs7780.c	2009-08-31 16:17:52.851102203 -0700
+++ b/drivers/net/irda/mcs7780.c	2009-08-31 16:27:10.043581476 -0700
@@ -817,7 +817,8 @@ static void mcs_send_irq(struct urb *urb
 }
 
 /* Transmit callback funtion.  */
-static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t mcs_hard_xmit(struct sk_buff *skb,
+				       struct net_device *ndev)
 {
 	unsigned long flags;
 	struct mcs_cb *mcs;
--- a/drivers/net/irda/nsc-ircc.c	2009-08-31 16:17:52.781143518 -0700
+++ b/drivers/net/irda/nsc-ircc.c	2009-08-31 16:27:10.053607959 -0700
@@ -173,8 +173,10 @@ static int  nsc_ircc_setup(chipio_t *inf
 static void nsc_ircc_pio_receive(struct nsc_ircc_cb *self);
 static int  nsc_ircc_dma_receive(struct nsc_ircc_cb *self); 
 static int  nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase);
-static int  nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev);
-static int  nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t  nsc_ircc_hard_xmit_sir(struct sk_buff *skb,
+						 struct net_device *dev);
+static netdev_tx_t  nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
+						 struct net_device *dev);
 static int  nsc_ircc_pio_write(int iobase, __u8 *buf, int len, int fifo_size);
 static void nsc_ircc_dma_xmit(struct nsc_ircc_cb *self, int iobase);
 static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 baud);
@@ -1355,7 +1357,8 @@ static __u8 nsc_ircc_change_speed(struct
  *    Transmit the frame!
  *
  */
-static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t nsc_ircc_hard_xmit_sir(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct nsc_ircc_cb *self;
 	unsigned long flags;
@@ -1427,7 +1430,8 @@ static int nsc_ircc_hard_xmit_sir(struct
 	return NETDEV_TX_OK;
 }
 
-static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct nsc_ircc_cb *self;
 	unsigned long flags;
--- a/drivers/net/irda/sir_dev.c	2009-08-31 16:17:52.821112356 -0700
+++ b/drivers/net/irda/sir_dev.c	2009-08-31 16:27:10.053607959 -0700
@@ -582,7 +582,8 @@ EXPORT_SYMBOL(sirdev_receive);
 
 /* callbacks from network layer */
 
-static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t sirdev_hard_xmit(struct sk_buff *skb,
+					  struct net_device *ndev)
 {
 	struct sir_dev *dev = netdev_priv(ndev);
 	unsigned long flags;
--- a/drivers/net/irda/smsc-ircc2.c	2009-08-31 16:17:52.771108095 -0700
+++ b/drivers/net/irda/smsc-ircc2.c	2009-08-31 16:27:10.053607959 -0700
@@ -194,8 +194,10 @@ static int __exit smsc_ircc_close(struct
 static int  smsc_ircc_dma_receive(struct smsc_ircc_cb *self);
 static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self);
 static void smsc_ircc_sir_receive(struct smsc_ircc_cb *self);
-static int  smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev);
-static int  smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t  smsc_ircc_hard_xmit_sir(struct sk_buff *skb,
+						  struct net_device *dev);
+static netdev_tx_t  smsc_ircc_hard_xmit_fir(struct sk_buff *skb,
+						  struct net_device *dev);
 static void smsc_ircc_dma_xmit(struct smsc_ircc_cb *self, int bofs);
 static void smsc_ircc_dma_xmit_complete(struct smsc_ircc_cb *self);
 static void smsc_ircc_change_speed(struct smsc_ircc_cb *self, u32 speed);
@@ -486,7 +488,8 @@ static int __init smsc_ircc_init(void)
 	return ret;
 }
 
-static int smsc_ircc_net_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t smsc_ircc_net_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct smsc_ircc_cb *self = netdev_priv(dev);
 
@@ -878,7 +881,8 @@ static void smsc_ircc_timeout(struct net
  *    waits until the next transmit interrupt, and continues until the
  *    frame is transmitted.
  */
-static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t smsc_ircc_hard_xmit_sir(struct sk_buff *skb,
+						 struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 	unsigned long flags;
@@ -1183,7 +1187,8 @@ static void smsc_ircc_set_sir_speed(stru
  *    Transmit the frame!
  *
  */
-static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t smsc_ircc_hard_xmit_fir(struct sk_buff *skb,
+						 struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 	unsigned long flags;
--- a/drivers/net/irda/stir4200.c	2009-08-31 16:17:52.841087172 -0700
+++ b/drivers/net/irda/stir4200.c	2009-08-31 16:27:10.053607959 -0700
@@ -560,7 +560,8 @@ static int change_speed(struct stir_cb *
 /*
  * Called from net/core when new frame is available.
  */
-static int stir_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t stir_hard_xmit(struct sk_buff *skb,
+					struct net_device *netdev)
 {
 	struct stir_cb *stir = netdev_priv(netdev);
 
--- a/drivers/net/irda/via-ircc.c	2009-08-31 16:17:52.831086390 -0700
+++ b/drivers/net/irda/via-ircc.c	2009-08-31 16:27:10.053607959 -0700
@@ -87,10 +87,10 @@ static int via_ircc_close(struct via_irc
 static int via_ircc_dma_receive(struct via_ircc_cb *self);
 static int via_ircc_dma_receive_complete(struct via_ircc_cb *self,
 					 int iobase);
-static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
-				  struct net_device *dev);
-static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
-				  struct net_device *dev);
+static netdev_tx_t via_ircc_hard_xmit_sir(struct sk_buff *skb,
+						struct net_device *dev);
+static netdev_tx_t via_ircc_hard_xmit_fir(struct sk_buff *skb,
+						struct net_device *dev);
 static void via_hw_init(struct via_ircc_cb *self);
 static void via_ircc_change_speed(struct via_ircc_cb *self, __u32 baud);
 static irqreturn_t via_ircc_interrupt(int irq, void *dev_id);
@@ -823,8 +823,8 @@ static void via_ircc_change_speed(struct
  *    Transmit the frame!
  *
  */
-static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
-				  struct net_device *dev)
+static netdev_tx_t via_ircc_hard_xmit_sir(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct via_ircc_cb *self;
 	unsigned long flags;
@@ -895,8 +895,8 @@ static int via_ircc_hard_xmit_sir(struct
 	return NETDEV_TX_OK;
 }
 
-static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
-				  struct net_device *dev)
+static netdev_tx_t via_ircc_hard_xmit_fir(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct via_ircc_cb *self;
 	u16 iobase;
--- a/drivers/net/irda/vlsi_ir.c	2009-08-31 16:17:52.811133713 -0700
+++ b/drivers/net/irda/vlsi_ir.c	2009-08-31 16:27:10.053607959 -0700
@@ -854,7 +854,8 @@ static int vlsi_set_baud(vlsi_irda_dev_t
 	return ret;
 }
 
-static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
+					      struct net_device *ndev)
 {
 	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring	*r = idev->tx_ring;
--- a/drivers/net/irda/w83977af_ir.c	2009-08-31 16:17:52.831086390 -0700
+++ b/drivers/net/irda/w83977af_ir.c	2009-08-31 16:27:10.053607959 -0700
@@ -93,7 +93,8 @@ static int  w83977af_close(struct w83977
 static int  w83977af_probe(int iobase, int irq, int dma);
 static int  w83977af_dma_receive(struct w83977af_ir *self); 
 static int  w83977af_dma_receive_complete(struct w83977af_ir *self);
-static int  w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t  w83977af_hard_xmit(struct sk_buff *skb,
+					     struct net_device *dev);
 static int  w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size);
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase);
 static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed);
@@ -490,7 +491,8 @@ static void w83977af_change_speed(struct
  *    Sets up a DMA transfer to send the current frame.
  *
  */
-static int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct w83977af_ir *self;
 	__s32 speed;
--- a/net/irda/irlan/irlan_eth.c	2009-08-31 16:17:52.771108095 -0700
+++ b/net/irda/irlan/irlan_eth.c	2009-08-31 16:27:10.053607959 -0700
@@ -41,7 +41,8 @@
 
 static int  irlan_eth_open(struct net_device *dev);
 static int  irlan_eth_close(struct net_device *dev);
-static int  irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t  irlan_eth_xmit(struct sk_buff *skb,
+					 struct net_device *dev);
 static void irlan_eth_set_multicast_list( struct net_device *dev);
 static struct net_device_stats *irlan_eth_get_stats(struct net_device *dev);
 
@@ -162,7 +163,8 @@ static int irlan_eth_close(struct net_de
  *    Transmits ethernet frames over IrDA link.
  *
  */
-static int irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t irlan_eth_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 	int ret;
--- a/drivers/net/irda/mcs7780.h	2009-08-31 16:17:52.801108556 -0700
+++ b/drivers/net/irda/mcs7780.h	2009-08-31 16:27:10.053607959 -0700
@@ -156,7 +156,8 @@ static int mcs_net_open(struct net_devic
 
 static void mcs_receive_irq(struct urb *urb);
 static void mcs_send_irq(struct urb *urb);
-static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *netdev);
+static netdev_tx_t mcs_hard_xmit(struct sk_buff *skb,
+				       struct net_device *netdev);
 
 static int mcs_probe(struct usb_interface *intf,
 		     const struct usb_device_id *id);
--- a/drivers/net/irda/donauboe.c	2009-08-31 16:17:52.781143518 -0700
+++ b/drivers/net/irda/donauboe.c	2009-08-31 16:27:10.053607959 -0700
@@ -970,7 +970,7 @@ toshoboe_probe (struct toshoboe_cb *self
 /* Netdev style code */
 
 /* Transmit something */
-static int
+static netdev_tx_t
 toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 {
   struct toshoboe_cb *self;

-- 

