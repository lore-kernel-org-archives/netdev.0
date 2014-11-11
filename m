From: Joe Perches <joe@perches.com>
Subject: [PATCH] irda: Remove IRDA_<TYPE> logging macros
Date: Tue, 11 Nov 2014 13:37:30 -0800
Message-ID: <1415741850.16070.13.camel@perches.com>
References: <1415740421.16070.11.camel@perches.com>
	 <20141111.162257.701721486580745428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0075.hostedemail.com ([216.40.44.75]:52783 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751983AbaKKVhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:37:37 -0500
In-Reply-To: <20141111.162257.701721486580745428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And use the more common mechanisms directly.

Other miscellanea:

o Coalesce formats
o Add missing newlines
o Realign arguments
o Remove unnecessary OOM message logging as
  there's a generic stack dump already on OOM.

Signed-off-by: Joe Perches <joe@perches.com>
---

Some long line warnings still exist for individual variables.
switch/case style was also not changed.

 drivers/net/irda/act200l-sir.c      |   3 +-
 drivers/net/irda/ali-ircc.c         |  57 ++++++++--------
 drivers/net/irda/girbil-sir.c       |   6 +-
 drivers/net/irda/irda-usb.c         |  47 +++++++------
 drivers/net/irda/irtty-sir.c        |  10 +--
 drivers/net/irda/ma600-sir.c        |   6 +-
 drivers/net/irda/mcp2120-sir.c      |   6 +-
 drivers/net/irda/mcs7780.c          |  45 +++++++------
 drivers/net/irda/nsc-ircc.c         |  66 +++++++++---------
 drivers/net/irda/sir_dev.c          |  35 +++++-----
 drivers/net/irda/smsc-ircc2.c       | 130 +++++++++++++++++++-----------------
 drivers/net/irda/tekram-sir.c       |   3 +-
 drivers/net/irda/via-ircc.c         |  21 +++---
 drivers/net/irda/vlsi_ir.c          | 118 +++++++++++++++++---------------
 drivers/net/irda/vlsi_ir.h          |   3 +-
 drivers/net/irda/w83977af_ir.c      |   9 +--
 include/net/irda/irda.h             |   4 --
 net/irda/af_irda.c                  |  34 +++++-----
 net/irda/ircomm/ircomm_core.c       |   5 +-
 net/irda/ircomm/ircomm_lmp.c        |   2 +-
 net/irda/ircomm/ircomm_param.c      |   3 +-
 net/irda/ircomm/ircomm_ttp.c        |  10 +--
 net/irda/ircomm/ircomm_tty.c        |  21 +++---
 net/irda/ircomm/ircomm_tty_attach.c |  12 ++--
 net/irda/ircomm/ircomm_tty_ioctl.c  |   3 +-
 net/irda/irda_device.c              |  18 ++---
 net/irda/iriap.c                    |  24 +++----
 net/irda/iriap_event.c              |   4 +-
 net/irda/irias_object.c             |  64 ++++++++----------
 net/irda/irlan/irlan_client.c       |  22 +++---
 net/irda/irlan/irlan_client_event.c |   4 +-
 net/irda/irlan/irlan_common.c       |   3 +-
 net/irda/irlan/irlan_eth.c          |   2 +-
 net/irda/irlap.c                    |  15 +++--
 net/irda/irlap_event.c              |   5 +-
 net/irda/irlap_frame.c              |  30 ++++-----
 net/irda/irlmp.c                    |  19 +++---
 net/irda/irlmp_event.c              |   8 +--
 net/irda/irttp.c                    |  31 ++++-----
 net/irda/parameters.c               |  39 +++++------
 net/irda/qos.c                      |  12 ++--
 net/irda/wrapper.c                  |   6 +-
 42 files changed, 486 insertions(+), 479 deletions(-)

diff --git a/drivers/net/irda/act200l-sir.c b/drivers/net/irda/act200l-sir.c
index 8ff084f..a911645 100644
--- a/drivers/net/irda/act200l-sir.c
+++ b/drivers/net/irda/act200l-sir.c
@@ -240,7 +240,8 @@ static int act200l_reset(struct sir_dev *dev)
 		dev->speed = 9600;
 		break;
 	default:
-		IRDA_ERROR("%s(), unknown state %d\n", __func__, state);
+		net_err_ratelimited("%s(), unknown state %d\n",
+				    __func__, state);
 		ret = -1;
 		break;
 	}
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index befa45f..7f23e5f 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -158,8 +158,8 @@ static int __init ali_ircc_init(void)
 
 	ret = platform_driver_register(&ali_ircc_driver);
         if (ret) {
-                IRDA_ERROR("%s, Can't register driver!\n",
-			   ALI_IRCC_DRIVER_NAME);
+		net_err_ratelimited("%s, Can't register driver!\n",
+				    ALI_IRCC_DRIVER_NAME);
                 return ret;
         }
 
@@ -292,8 +292,8 @@ static int ali_ircc_open(int i, chipio_t *info)
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 
 	if (i >= ARRAY_SIZE(dev_self)) {
-		IRDA_ERROR("%s(), maximum number of supported chips reached!\n",
-			   __func__);
+		net_err_ratelimited("%s(), maximum number of supported chips reached!\n",
+				    __func__);
 		return -ENOMEM;
 	}
 	
@@ -303,8 +303,8 @@ static int ali_ircc_open(int i, chipio_t *info)
 		
 	dev = alloc_irdadev(sizeof(*self));
 	if (dev == NULL) {
-		IRDA_ERROR("%s(), can't allocate memory for control block!\n",
-			   __func__);
+		net_err_ratelimited("%s(), can't allocate memory for control block!\n",
+				    __func__);
 		return -ENOMEM;
 	}
 
@@ -328,8 +328,8 @@ static int ali_ircc_open(int i, chipio_t *info)
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext,
 			    ALI_IRCC_DRIVER_NAME)) {
-		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n", __func__,
-			self->io.fir_base);
+		net_warn_ratelimited("%s(), can't get iobase of 0x%03x\n",
+				     __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
 	}
@@ -380,15 +380,17 @@ static int ali_ircc_open(int i, chipio_t *info)
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
+		net_err_ratelimited("%s(), register_netdev() failed!\n",
+				    __func__);
 		goto err_out4;
 	}
-	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
+	net_info_ratelimited("IrDA: Registered device %s\n", dev->name);
 
 	/* Check dongle id */
 	dongle_id = ali_ircc_read_dongle_id(i, info);
-	IRDA_MESSAGE("%s(), %s, Found dongle: %s\n", __func__,
-		     ALI_IRCC_DRIVER_NAME, dongle_types[dongle_id]);
+	net_info_ratelimited("%s(), %s, Found dongle: %s\n",
+			     __func__, ALI_IRCC_DRIVER_NAME,
+			     dongle_types[dongle_id]);
 		
 	self->io.dongle_id = dongle_id;
 
@@ -521,7 +523,8 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
 	info->dma = reg & 0x07;
 	
 	if(info->dma == 0x04)
-		IRDA_WARNING("%s(), No DMA channel assigned !\n", __func__);
+		net_warn_ratelimited("%s(), No DMA channel assigned !\n",
+				     __func__);
 	else
 		IRDA_DEBUG(2, "%s(), probing dma=%d\n", __func__, info->dma);
 	
@@ -578,8 +581,8 @@ static int ali_ircc_setup(chipio_t *info)
 	/* Should be 0x00 in the M1535/M1535D */
 	if(version != 0x00)
 	{
-		IRDA_ERROR("%s, Wrong chip version %02x\n",
-			   ALI_IRCC_DRIVER_NAME, version);
+		net_err_ratelimited("%s, Wrong chip version %02x\n",
+				    ALI_IRCC_DRIVER_NAME, version);
 		return -1;
 	}
 	
@@ -612,8 +615,8 @@ static int ali_ircc_setup(chipio_t *info)
 	/* Switch to SIR space */
 	FIR2SIR(iobase);
 	
-	IRDA_MESSAGE("%s, driver loaded (Benjamin Kong)\n",
-		     ALI_IRCC_DRIVER_NAME);
+	net_info_ratelimited("%s, driver loaded (Benjamin Kong)\n",
+			     ALI_IRCC_DRIVER_NAME);
 	
 	/* Enable receive interrupts */ 
 	// outb(UART_IER_RDI, iobase+UART_IER); //benjamin 2000/11/23 01:25PM
@@ -1352,9 +1355,8 @@ static int ali_ircc_net_open(struct net_device *dev)
 	/* Request IRQ and install Interrupt Handler */
 	if (request_irq(self->io.irq, ali_ircc_interrupt, 0, dev->name, dev)) 
 	{
-		IRDA_WARNING("%s, unable to allocate irq=%d\n",
-			     ALI_IRCC_DRIVER_NAME,
-			     self->io.irq);
+		net_warn_ratelimited("%s, unable to allocate irq=%d\n",
+				     ALI_IRCC_DRIVER_NAME, self->io.irq);
 		return -EAGAIN;
 	}
 	
@@ -1363,9 +1365,8 @@ static int ali_ircc_net_open(struct net_device *dev)
 	 * failure.
 	 */
 	if (request_dma(self->io.dma, dev->name)) {
-		IRDA_WARNING("%s, unable to allocate dma=%d\n",
-			     ALI_IRCC_DRIVER_NAME,
-			     self->io.dma);
+		net_warn_ratelimited("%s, unable to allocate dma=%d\n",
+				     ALI_IRCC_DRIVER_NAME, self->io.dma);
 		free_irq(self->io.irq, dev);
 		return -EAGAIN;
 	}
@@ -1671,7 +1672,8 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 	if((inb(iobase+FIR_LSR) & LSR_FRAME_ABORT) == LSR_FRAME_ABORT)
 	
 	{
-		IRDA_ERROR("%s(), ********* LSR_FRAME_ABORT *********\n", __func__);
+		net_err_ratelimited("%s(), ********* LSR_FRAME_ABORT *********\n",
+				    __func__);
 		self->netdev->stats.tx_errors++;
 		self->netdev->stats.tx_fifo_errors++;
 	}
@@ -1918,9 +1920,6 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  
 			{
-				IRDA_WARNING("%s(), memory squeeze, "
-					     "dropping frame.\n",
-					     __func__);
 				self->netdev->stats.rx_dropped++;
 
 				return FALSE;
@@ -2127,7 +2126,7 @@ static int ali_ircc_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct ali_ircc_cb *self = platform_get_drvdata(dev);
 	
-	IRDA_MESSAGE("%s, Suspending\n", ALI_IRCC_DRIVER_NAME);
+	net_info_ratelimited("%s, Suspending\n", ALI_IRCC_DRIVER_NAME);
 
 	if (self->io.suspended)
 		return 0;
@@ -2148,7 +2147,7 @@ static int ali_ircc_resume(struct platform_device *dev)
 	
 	ali_ircc_net_open(self->netdev);
 	
-	IRDA_MESSAGE("%s, Waking up\n", ALI_IRCC_DRIVER_NAME);
+	net_info_ratelimited("%s, Waking up\n", ALI_IRCC_DRIVER_NAME);
 
 	self->io.suspended = 0;
 
diff --git a/drivers/net/irda/girbil-sir.c b/drivers/net/irda/girbil-sir.c
index 96cdecf..f0512ad 100644
--- a/drivers/net/irda/girbil-sir.c
+++ b/drivers/net/irda/girbil-sir.c
@@ -179,7 +179,8 @@ static int girbil_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		IRDA_ERROR("%s - undefined state %d\n", __func__, state);
+		net_err_ratelimited("%s - undefined state %d\n",
+				    __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -241,7 +242,8 @@ static int girbil_reset(struct sir_dev *dev)
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefined state %d\n", __func__, state);
+		net_err_ratelimited("%s(), undefined state %d\n",
+				    __func__, state);
 		ret = -1;
 		break;
 	}
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 925b78c..e9aedbe 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -307,7 +307,7 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
 	/* Grab the speed URB */
 	urb = self->speed_urb;
 	if (urb->status != 0) {
-		IRDA_WARNING("%s(), URB still in use!\n", __func__);
+		net_warn_ratelimited("%s(), URB still in use!\n", __func__);
 		return;
 	}
 
@@ -333,7 +333,7 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
 
 	/* Irq disabled -> GFP_ATOMIC */
 	if ((ret = usb_submit_urb(urb, GFP_ATOMIC))) {
-		IRDA_WARNING("%s(), failed Speed URB\n", __func__);
+		net_warn_ratelimited("%s(), failed Speed URB\n", __func__);
 	}
 }
 
@@ -435,7 +435,7 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 	}
 
 	if (urb->status != 0) {
-		IRDA_WARNING("%s(), URB still in use!\n", __func__);
+		net_warn_ratelimited("%s(), URB still in use!\n", __func__);
 		goto drop;
 	}
 
@@ -522,7 +522,7 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 	
 	/* Ask USB to send the packet - Irq disabled -> GFP_ATOMIC */
 	if ((res = usb_submit_urb(urb, GFP_ATOMIC))) {
-		IRDA_WARNING("%s(), failed Tx URB\n", __func__);
+		net_warn_ratelimited("%s(), failed Tx URB\n", __func__);
 		netdev->stats.tx_errors++;
 		/* Let USB recover : We will catch that in the watchdog */
 		/*netif_start_queue(netdev);*/
@@ -638,7 +638,7 @@ static void irda_usb_net_timeout(struct net_device *netdev)
 
 	/* self->present *MUST* be read under spinlock */
 	if (!self->present) {
-		IRDA_WARNING("%s(), device not present!\n", __func__);
+		net_warn_ratelimited("%s(), device not present!\n", __func__);
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&self->lock, flags);
 		return;
@@ -783,8 +783,8 @@ static void irda_usb_submit(struct irda_usb_cb *self, struct sk_buff *skb, struc
 	if (ret) {
 		/* If this ever happen, we are in deep s***.
 		 * Basically, the Rx path will stop... */
-		IRDA_WARNING("%s(), Failed to submit Rx URB %d\n",
-			     __func__, ret);
+		net_warn_ratelimited("%s(), Failed to submit Rx URB %d\n",
+				     __func__, ret);
 	}
 }
 
@@ -859,7 +859,7 @@ static void irda_usb_receive(struct urb *urb)
 	
 	/* Check for empty frames */
 	if (urb->actual_length <= self->header_length) {
-		IRDA_WARNING("%s(), empty frame!\n", __func__);
+		net_warn_ratelimited("%s(), empty frame!\n", __func__);
 		goto done;
 	}
 
@@ -1088,8 +1088,8 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
                 return ret;
 
         /* We get a patch from userspace */
-        IRDA_MESSAGE("%s(): Received firmware %s (%zu bytes)\n",
-                     __func__, stir421x_fw_name, fw->size);
+	net_info_ratelimited("%s(): Received firmware %s (%zu bytes)\n",
+			     __func__, stir421x_fw_name, fw->size);
 
         ret = -EINVAL;
 
@@ -1179,13 +1179,13 @@ static int irda_usb_net_open(struct net_device *netdev)
 	/* Can only open the device if it's there */
 	if(!self->present) {
 		spin_unlock_irqrestore(&self->lock, flags);
-		IRDA_WARNING("%s(), device not present!\n", __func__);
+		net_warn_ratelimited("%s(), device not present!\n", __func__);
 		return -1;
 	}
 
 	if(self->needspatch) {
 		spin_unlock_irqrestore(&self->lock, flags);
-		IRDA_WARNING("%s(), device needs patch\n", __func__) ;
+		net_warn_ratelimited("%s(), device needs patch\n", __func__);
 		return -EIO ;
 	}
 
@@ -1227,8 +1227,6 @@ static int irda_usb_net_open(struct net_device *netdev)
 		if (!skb) {
 			/* If this ever happen, we are in deep s***.
 			 * Basically, we can't start the Rx path... */
-			IRDA_WARNING("%s(), Failed to allocate Rx skb\n",
-				     __func__);
 			return -1;
 		}
 		//skb_reserve(newskb, USB_IRDA_HEADER - 1);
@@ -1505,7 +1503,8 @@ static inline int irda_usb_parse_endpoints(struct irda_usb_cb *self, struct usb_
 				/* This is our interrupt endpoint */
 				self->bulk_int_ep = ep;
 			} else {
-				IRDA_ERROR("%s(), Unrecognised endpoint %02X.\n", __func__, ep);
+				net_err_ratelimited("%s(), Unrecognised endpoint %02X\n",
+						    __func__, ep);
 			}
 		}
 	}
@@ -1575,11 +1574,11 @@ static inline struct irda_class_desc *irda_usb_find_class_desc(struct usb_interf
 	
 	IRDA_DEBUG(1, "%s(), ret=%d\n", __func__, ret);
 	if (ret < sizeof(*desc)) {
-		IRDA_WARNING("usb-irda: class_descriptor read %s (%d)\n",
-			     (ret<0) ? "failed" : "too short", ret);
+		net_warn_ratelimited("usb-irda: class_descriptor read %s (%d)\n",
+				     ret < 0 ? "failed" : "too short", ret);
 	}
 	else if (desc->bDescriptorType != USB_DT_IRDA) {
-		IRDA_WARNING("usb-irda: bad class_descriptor type\n");
+		net_warn_ratelimited("usb-irda: bad class_descriptor type\n");
 	}
 	else {
 #ifdef IU_DUMP_CLASS_DESC
@@ -1622,9 +1621,9 @@ static int irda_usb_probe(struct usb_interface *intf,
 	 * don't need to check if the dongle is really ours.
 	 * Jean II */
 
-	IRDA_MESSAGE("IRDA-USB found at address %d, Vendor: %x, Product: %x\n",
-		     dev->devnum, le16_to_cpu(dev->descriptor.idVendor),
-		     le16_to_cpu(dev->descriptor.idProduct));
+	net_info_ratelimited("IRDA-USB found at address %d, Vendor: %x, Product: %x\n",
+			     dev->devnum, le16_to_cpu(dev->descriptor.idVendor),
+			     le16_to_cpu(dev->descriptor.idProduct));
 
 	net = alloc_irdadev(sizeof(*self));
 	if (!net) 
@@ -1700,7 +1699,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 	interface = intf->cur_altsetting;
 	if(!irda_usb_parse_endpoints(self, interface->endpoint,
 				     interface->desc.bNumEndpoints)) {
-		IRDA_ERROR("%s(), Bogus endpoints...\n", __func__);
+		net_err_ratelimited("%s(), Bogus endpoints...\n", __func__);
 		ret = -EIO;
 		goto err_out_3;
 	}
@@ -1746,7 +1745,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 	if (ret) 
 		goto err_out_5;
 
-	IRDA_MESSAGE("IrDA: Registered device %s\n", net->name);
+	net_info_ratelimited("IrDA: Registered device %s\n", net->name);
 	usb_set_intfdata(intf, self);
 
 	if (self->needspatch) {
@@ -1754,7 +1753,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 		ret = stir421x_patch_device(self);
 		self->needspatch = (ret < 0);
 		if (self->needspatch) {
-			IRDA_ERROR("STIR421X: Couldn't upload patch\n");
+			net_err_ratelimited("STIR421X: Couldn't upload patch\n");
 			goto err_out_6;
 		}
 
diff --git a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
index 24b6ddd..abbb654 100644
--- a/drivers/net/irda/irtty-sir.c
+++ b/drivers/net/irda/irtty-sir.c
@@ -231,7 +231,7 @@ static void irtty_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 
 	dev = priv->dev;
 	if (!dev) {
-		IRDA_WARNING("%s(), not ready yet!\n", __func__);
+		net_warn_ratelimited("%s(), not ready yet!\n", __func__);
 		return;
 	}
 
@@ -555,8 +555,8 @@ static int __init irtty_sir_init(void)
 	int err;
 
 	if ((err = tty_register_ldisc(N_IRDA, &irda_ldisc)) != 0)
-		IRDA_ERROR("IrDA: can't register line discipline (err = %d)\n",
-			   err);
+		net_err_ratelimited("IrDA: can't register line discipline (err = %d)\n",
+				    err);
 	return err;
 }
 
@@ -565,8 +565,8 @@ static void __exit irtty_sir_cleanup(void)
 	int err;
 
 	if ((err = tty_unregister_ldisc(N_IRDA))) {
-		IRDA_ERROR("%s(), can't unregister line discipline (err = %d)\n",
-			   __func__, err);
+		net_err_ratelimited("%s(), can't unregister line discipline (err = %d)\n",
+				    __func__, err);
 	}
 }
 
diff --git a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
index a9a8135..944d044 100644
--- a/drivers/net/irda/ma600-sir.c
+++ b/drivers/net/irda/ma600-sir.c
@@ -198,9 +198,9 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
 
 	sirdev_raw_read(dev, &byte, sizeof(byte));
 	if (byte != get_control_byte(speed))  {
-		IRDA_WARNING("%s(): bad control byte read-back %02x != %02x\n",
-			     __func__, (unsigned) byte,
-			     (unsigned) get_control_byte(speed));
+		net_warn_ratelimited("%s(): bad control byte read-back %02x != %02x\n",
+				     __func__, (unsigned)byte,
+				     (unsigned)get_control_byte(speed));
 		return -1;
 	}
 	else
diff --git a/drivers/net/irda/mcp2120-sir.c b/drivers/net/irda/mcp2120-sir.c
index 5e2f485..9767469 100644
--- a/drivers/net/irda/mcp2120-sir.c
+++ b/drivers/net/irda/mcp2120-sir.c
@@ -155,7 +155,8 @@ static int mcp2120_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefine state %d\n", __func__, state);
+		net_err_ratelimited("%s(), undefine state %d\n",
+				    __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -213,7 +214,8 @@ static int mcp2120_reset(struct sir_dev *dev)
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefined state %d\n", __func__, state);
+		net_err_ratelimited("%s(), undefined state %d\n",
+				    __func__, state);
 		ret = -EINVAL;
 		break;
 	}
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 16f8ffb..6cbd29d 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -197,14 +197,14 @@ error:
 /* Setup a communication between mcs7780 and agilent chip. */
 static inline int mcs_setup_transceiver_agilent(struct mcs_cb *mcs)
 {
-	IRDA_WARNING("This transceiver type is not supported yet.\n");
+	net_warn_ratelimited("This transceiver type is not supported yet\n");
 	return 1;
 }
 
 /* Setup a communication between mcs7780 and sharp chip. */
 static inline int mcs_setup_transceiver_sharp(struct mcs_cb *mcs)
 {
-	IRDA_WARNING("This transceiver type is not supported yet.\n");
+	net_warn_ratelimited("This transceiver type is not supported yet\n");
 	return 1;
 }
 
@@ -213,9 +213,9 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 {
 	int ret = 0;
 	__u16 rval;
-	char *msg;
+	const char *msg;
 
-	msg = "Basic transceiver setup error.";
+	msg = "Basic transceiver setup error";
 
 	/* read value of MODE Register, set the DRIVER and RESET bits
 	* and write value back out to MODE Register
@@ -261,7 +261,7 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 	if(unlikely(ret))
 		goto error;
 
-	msg = "transceiver model specific setup error.";
+	msg = "transceiver model specific setup error";
 	switch (mcs->transceiver_type) {
 	case MCS_TSC_VISHAY:
 		ret = mcs_setup_transceiver_vishay(mcs);
@@ -276,8 +276,8 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 		break;
 
 	default:
-		IRDA_WARNING("Unknown transceiver type: %d\n",
-			     mcs->transceiver_type);
+		net_warn_ratelimited("Unknown transceiver type: %d\n",
+				     mcs->transceiver_type);
 		ret = 1;
 	}
 	if (unlikely(ret))
@@ -300,7 +300,7 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 			goto error;
 	}
 
-	msg = "transceiver reset.";
+	msg = "transceiver reset";
 
 	ret = mcs_get_reg(mcs, MCS_MODE_REG, &rval);
 	if (unlikely(ret != 2))
@@ -315,7 +315,7 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 		return ret;
 
 error:
-	IRDA_ERROR("%s\n", msg);
+	net_err_ratelimited("%s\n", msg);
 	return ret;
 }
 
@@ -399,8 +399,8 @@ static void mcs_unwrap_mir(struct mcs_cb *mcs, __u8 *buf, int len)
 
 	new_len = len - 2;
 	if(unlikely(new_len <= 0)) {
-		IRDA_ERROR("%s short frame length %d\n",
-			     mcs->netdev->name, new_len);
+		net_err_ratelimited("%s short frame length %d\n",
+				    mcs->netdev->name, new_len);
 		++mcs->netdev->stats.rx_errors;
 		++mcs->netdev->stats.rx_length_errors;
 		return;
@@ -409,8 +409,8 @@ static void mcs_unwrap_mir(struct mcs_cb *mcs, __u8 *buf, int len)
 	fcs = irda_calc_crc16(~fcs, buf, len);
 
 	if(fcs != GOOD_FCS) {
-		IRDA_ERROR("crc error calc 0x%x len %d\n",
-			   fcs, new_len);
+		net_err_ratelimited("crc error calc 0x%x len %d\n",
+				    fcs, new_len);
 		mcs->netdev->stats.rx_errors++;
 		mcs->netdev->stats.rx_crc_errors++;
 		return;
@@ -452,8 +452,8 @@ static void mcs_unwrap_fir(struct mcs_cb *mcs, __u8 *buf, int len)
 
 	new_len = len - 4;
 	if(unlikely(new_len <= 0)) {
-		IRDA_ERROR("%s short frame length %d\n",
-			   mcs->netdev->name, new_len);
+		net_err_ratelimited("%s short frame length %d\n",
+				    mcs->netdev->name, new_len);
 		++mcs->netdev->stats.rx_errors;
 		++mcs->netdev->stats.rx_length_errors;
 		return;
@@ -461,7 +461,8 @@ static void mcs_unwrap_fir(struct mcs_cb *mcs, __u8 *buf, int len)
 
 	fcs = ~(crc32_le(~0, buf, new_len));
 	if(fcs != get_unaligned_le32(buf + new_len)) {
-		IRDA_ERROR("crc error calc 0x%x len %d\n", fcs, new_len);
+		net_err_ratelimited("crc error calc 0x%x len %d\n",
+				    fcs, new_len);
 		mcs->netdev->stats.rx_errors++;
 		mcs->netdev->stats.rx_crc_errors++;
 		return;
@@ -583,7 +584,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 	} while(cnt++ < 100 && (rval & MCS_IRINTX));
 
 	if (cnt > 100) {
-		IRDA_ERROR("unable to change speed\n");
+		net_err_ratelimited("unable to change speed\n");
 		ret = -EIO;
 		goto error;
 	}
@@ -634,8 +635,8 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 
 		default:
 			ret = 1;
-			IRDA_WARNING("Unknown transceiver type: %d\n",
-				     mcs->transceiver_type);
+			net_warn_ratelimited("Unknown transceiver type: %d\n",
+					     mcs->transceiver_type);
 		}
 	if (unlikely(ret))
 		goto error;
@@ -731,7 +732,7 @@ static int mcs_net_open(struct net_device *netdev)
 	sprintf(hwname, "usb#%d", mcs->usbdev->devnum);
 	mcs->irlap = irlap_open(netdev, &mcs->qos, hwname);
 	if (!mcs->irlap) {
-		IRDA_ERROR("mcs7780: irlap_open failed\n");
+		net_err_ratelimited("mcs7780: irlap_open failed\n");
 		goto error2;
 	}
 
@@ -851,7 +852,7 @@ static netdev_tx_t mcs_hard_xmit(struct sk_buff *skb,
 			  mcs->out_buf, wraplen, mcs_send_irq, mcs);
 
 	if ((ret = usb_submit_urb(mcs->tx_urb, GFP_ATOMIC))) {
-		IRDA_ERROR("failed tx_urb: %d\n", ret);
+		net_err_ratelimited("failed tx_urb: %d\n", ret);
 		switch (ret) {
 		case -ENODEV:
 		case -EPIPE:
@@ -899,7 +900,7 @@ static int mcs_probe(struct usb_interface *intf,
 
 	ret = usb_reset_configuration(udev);
 	if (ret != 0) {
-		IRDA_ERROR("mcs7780: usb reset configuration failed\n");
+		net_err_ratelimited("mcs7780: usb reset configuration failed\n");
 		goto error2;
 	}
 
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 66bc03b..c0a1790 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -211,7 +211,8 @@ static int __init nsc_ircc_init(void)
 
 	ret = platform_driver_register(&nsc_ircc_driver);
         if (ret) {
-                IRDA_ERROR("%s, Can't register driver!\n", driver_name);
+		net_err_ratelimited("%s, Can't register driver!\n",
+				    driver_name);
                 return ret;
         }
 
@@ -260,7 +261,8 @@ static int __init nsc_ircc_init(void)
 					info.irq = pnp_info.irq;
 
 					if (info.fir_base < 0x2000) {
-						IRDA_MESSAGE("%s, chip->init\n", driver_name);
+						net_info_ratelimited("%s, chip->init\n",
+								     driver_name);
 						chip->init(chip, &info);
 					} else
 						chip->probe(chip, &info);
@@ -370,22 +372,23 @@ static int __init nsc_ircc_open(chipio_t *info)
 	}
 
 	if (chip_index == ARRAY_SIZE(dev_self)) {
-		IRDA_ERROR("%s(), maximum number of supported chips reached!\n", __func__);
+		net_err_ratelimited("%s(), maximum number of supported chips reached!\n",
+				    __func__);
 		return -ENOMEM;
 	}
 
-	IRDA_MESSAGE("%s, Found chip at base=0x%03x\n", driver_name,
-		     info->cfg_base);
+	net_info_ratelimited("%s, Found chip at base=0x%03x\n",
+			     driver_name, info->cfg_base);
 
 	if ((nsc_ircc_setup(info)) == -1)
 		return -1;
 
-	IRDA_MESSAGE("%s, driver loaded (Dag Brattli)\n", driver_name);
+	net_info_ratelimited("%s, driver loaded (Dag Brattli)\n", driver_name);
 
 	dev = alloc_irdadev(sizeof(struct nsc_ircc_cb));
 	if (dev == NULL) {
-		IRDA_ERROR("%s(), can't allocate memory for "
-			   "control block!\n", __func__);
+		net_err_ratelimited("%s(), can't allocate memory for control block!\n",
+				    __func__);
 		return -ENOMEM;
 	}
 
@@ -408,8 +411,8 @@ static int __init nsc_ircc_open(chipio_t *info)
 	/* Reserve the ioports that we need */
 	ret = request_region(self->io.fir_base, self->io.fir_ext, driver_name);
 	if (!ret) {
-		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n",
-			     __func__, self->io.fir_base);
+		net_warn_ratelimited("%s(), can't get iobase of 0x%03x\n",
+				     __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto out1;
 	}
@@ -460,21 +463,22 @@ static int __init nsc_ircc_open(chipio_t *info)
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
+		net_err_ratelimited("%s(), register_netdev() failed!\n",
+				    __func__);
 		goto out4;
 	}
-	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
+	net_info_ratelimited("IrDA: Registered device %s\n", dev->name);
 
 	/* Check if user has supplied a valid dongle id or not */
 	if ((dongle_id <= 0) ||
 	    (dongle_id >= ARRAY_SIZE(dongle_types))) {
 		dongle_id = nsc_ircc_read_dongle_id(self->io.fir_base);
 		
-		IRDA_MESSAGE("%s, Found dongle: %s\n", driver_name,
-			     dongle_types[dongle_id]);
+		net_info_ratelimited("%s, Found dongle: %s\n",
+				     driver_name, dongle_types[dongle_id]);
 	} else {
-		IRDA_MESSAGE("%s, Using dongle: %s\n", driver_name,
-			     dongle_types[dongle_id]);
+		net_info_ratelimited("%s, Using dongle: %s\n",
+				     driver_name, dongle_types[dongle_id]);
 	}
 	
 	self->io.dongle_id = dongle_id;
@@ -567,7 +571,7 @@ static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info)
 	case 0x2e8: outb(0x15, cfg_base+1); break;
 	case 0x3f8: outb(0x16, cfg_base+1); break;
 	case 0x2f8: outb(0x17, cfg_base+1); break;
-	default: IRDA_ERROR("%s(), invalid base_address", __func__);
+	default: net_err_ratelimited("%s(), invalid base_address\n", __func__);
 	}
 	
 	/* Control Signal Routing Register (CSRT) */
@@ -579,7 +583,7 @@ static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info)
 	case 9:  temp = 0x05; break;
 	case 11: temp = 0x06; break;
 	case 15: temp = 0x07; break;
-	default: IRDA_ERROR("%s(), invalid irq", __func__);
+	default: net_err_ratelimited("%s(), invalid irq\n", __func__);
 	}
 	outb(CFG_108_CSRT, cfg_base);
 	
@@ -587,7 +591,7 @@ static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info)
 	case 0: outb(0x08+temp, cfg_base+1); break;
 	case 1: outb(0x10+temp, cfg_base+1); break;
 	case 3: outb(0x18+temp, cfg_base+1); break;
-	default: IRDA_ERROR("%s(), invalid dma", __func__);
+	default: net_err_ratelimited("%s(), invalid dma\n", __func__);
 	}
 	
 	outb(CFG_108_MCTL, cfg_base);      /* Mode Control Register (MCTL) */
@@ -993,8 +997,8 @@ static int nsc_ircc_setup(chipio_t *info)
 
 	/* Should be 0x2? */
 	if (0x20 != (version & 0xf0)) {
-		IRDA_ERROR("%s, Wrong chip version %02x\n",
-			   driver_name, version);
+		net_err_ratelimited("%s, Wrong chip version %02x\n",
+				    driver_name, version);
 		return -1;
 	}
 
@@ -1872,9 +1876,6 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  {
-				IRDA_WARNING("%s(), memory squeeze, "
-					     "dropping frame.\n",
-					     __func__);
 				self->netdev->stats.rx_dropped++;
 
 				/* Restore bank register */
@@ -2063,9 +2064,8 @@ static void nsc_ircc_fir_interrupt(struct nsc_ircc_cb *self, int iobase,
 					nsc_ircc_dma_receive(self);
 					self->ier = IER_SFIF_IE;
 				} else
-					IRDA_WARNING("%s(), potential "
-						     "Tx queue lockup !\n",
-						     __func__);
+					net_warn_ratelimited("%s(), potential Tx queue lockup !\n",
+							     __func__);
 			}
 		} else {
 			/*  Not finished yet, so interrupt on DMA again */
@@ -2184,8 +2184,8 @@ static int nsc_ircc_net_open(struct net_device *dev)
 	iobase = self->io.fir_base;
 	
 	if (request_irq(self->io.irq, nsc_ircc_interrupt, 0, dev->name, dev)) {
-		IRDA_WARNING("%s, unable to allocate irq=%d\n",
-			     driver_name, self->io.irq);
+		net_warn_ratelimited("%s, unable to allocate irq=%d\n",
+				     driver_name, self->io.irq);
 		return -EAGAIN;
 	}
 	/*
@@ -2193,8 +2193,8 @@ static int nsc_ircc_net_open(struct net_device *dev)
 	 * failure.
 	 */
 	if (request_dma(self->io.dma, dev->name)) {
-		IRDA_WARNING("%s, unable to allocate dma=%d\n",
-			     driver_name, self->io.dma);
+		net_warn_ratelimited("%s, unable to allocate dma=%d\n",
+				     driver_name, self->io.dma);
 		free_irq(self->io.irq, dev);
 		return -EAGAIN;
 	}
@@ -2372,8 +2372,8 @@ static int nsc_ircc_resume(struct platform_device *dev)
 	if (netif_running(self->netdev)) {
 		if (request_irq(self->io.irq, nsc_ircc_interrupt, 0,
 				self->netdev->name, self->netdev)) {
- 		    	IRDA_WARNING("%s, unable to allocate irq=%d\n",
-				     driver_name, self->io.irq);
+			net_warn_ratelimited("%s, unable to allocate irq=%d\n",
+					     driver_name, self->io.irq);
 
 			/*
 			 * Don't fail resume process, just kill this
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 43e9ab4..5bfcd25 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -82,7 +82,7 @@ static int sirdev_tx_complete_fsm(struct sir_dev *dev)
 			return 0;
 
 		default:
-			IRDA_ERROR("%s - undefined state\n", __func__);
+			net_err_ratelimited("%s - undefined state\n", __func__);
 			return -EINVAL;
 		}
 		fsm->substate = next_state;
@@ -251,12 +251,13 @@ static void sirdev_config_fsm(struct work_struct *work)
 			break;
 
 		default:
-			IRDA_ERROR("%s - undefined state\n", __func__);
+			net_err_ratelimited("%s - undefined state\n", __func__);
 			fsm->result = -EINVAL;
 			/* fall thru */
 
 		case SIRDEV_STATE_ERROR:
-			IRDA_ERROR("%s - error: %d\n", __func__, fsm->result);
+			net_err_ratelimited("%s - error: %d\n",
+					    __func__, fsm->result);
 
 #if 0	/* don't enable this before we have netdev->tx_timeout to recover */
 			netif_stop_queue(dev->netdev);
@@ -299,7 +300,7 @@ int sirdev_schedule_request(struct sir_dev *dev, int initial_state, unsigned par
 
 	if (fsm->state == SIRDEV_STATE_DEAD) {
 		/* race with sirdev_close should never happen */
-		IRDA_ERROR("%s(), instance staled!\n", __func__);
+		net_err_ratelimited("%s(), instance staled!\n", __func__);
 		up(&fsm->sem);
 		return -ESTALE;		/* or better EPIPE? */
 	}
@@ -452,8 +453,8 @@ void sirdev_write_complete(struct sir_dev *dev)
 		}
 		else if (unlikely(actual<0)) {
 			/* could be dropped later when we have tx_timeout to recover */
-			IRDA_ERROR("%s: drv->do_write failed (%d)\n",
-				   __func__, actual);
+			net_err_ratelimited("%s: drv->do_write failed (%d)\n",
+					    __func__, actual);
 			if ((skb=dev->tx_skb) != NULL) {
 				dev->tx_skb = NULL;
 				dev_kfree_skb_any(skb);
@@ -507,8 +508,8 @@ void sirdev_write_complete(struct sir_dev *dev)
 			/* should never happen
 			 * forget the speed change and hope the stack recovers
 			 */
-			IRDA_ERROR("%s - schedule speed change failed: %d\n",
-				   __func__, err);
+			net_err_ratelimited("%s - schedule speed change failed: %d\n",
+					    __func__, err);
 			netif_wake_queue(dev->netdev);
 		}
 		/* else: success
@@ -535,13 +536,13 @@ EXPORT_SYMBOL(sirdev_write_complete);
 int sirdev_receive(struct sir_dev *dev, const unsigned char *cp, size_t count) 
 {
 	if (!dev || !dev->netdev) {
-		IRDA_WARNING("%s(), not ready yet!\n", __func__);
+		net_warn_ratelimited("%s(), not ready yet!\n", __func__);
 		return -1;
 	}
 
 	if (!dev->irlap) {
-		IRDA_WARNING("%s - too early: %p / %zd!\n",
-			     __func__, cp, count);
+		net_warn_ratelimited("%s - too early: %p / %zd!\n",
+				     __func__, cp, count);
 		return -1;
 	}
 
@@ -661,8 +662,8 @@ static netdev_tx_t sirdev_hard_xmit(struct sk_buff *skb,
 	}
 	else if (unlikely(actual < 0)) {
 		/* could be dropped later when we have tx_timeout to recover */
-		IRDA_ERROR("%s: drv->do_write failed (%d)\n",
-			   __func__, actual);
+		net_err_ratelimited("%s: drv->do_write failed (%d)\n",
+				    __func__, actual);
 		dev_kfree_skb_any(skb);
 		dev->netdev->stats.tx_errors++;
 		dev->netdev->stats.tx_dropped++;
@@ -894,7 +895,8 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	 */
 	ndev = alloc_irdadev(sizeof(*dev));
 	if (ndev == NULL) {
-		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __func__);
+		net_err_ratelimited("%s - Can't allocate memory for IrDA control block!\n",
+				    __func__);
 		goto out;
 	}
 	dev = netdev_priv(ndev);
@@ -919,7 +921,8 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	ndev->netdev_ops = &sirdev_ops;
 
 	if (register_netdev(ndev)) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
+		net_err_ratelimited("%s(), register_netdev() failed!\n",
+				    __func__);
 		goto out_freenetdev;
 	}
 
@@ -946,7 +949,7 @@ int sirdev_put_instance(struct sir_dev *dev)
 	if (dev->dongle_drv)
 		err = sirdev_schedule_dongle_close(dev);
 	if (err)
-		IRDA_ERROR("%s - error %d\n", __func__, err);
+		net_err_ratelimited("%s - error %d\n", __func__, err);
 
 	sirdev_close(dev->netdev);
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 2821204..a7f0f52 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -419,13 +419,16 @@ static int __init smsc_ircc_legacy_probe(void)
 #ifdef CONFIG_PCI
 	if (smsc_ircc_preconfigure_subsystems(ircc_cfg, ircc_fir, ircc_sir, ircc_dma, ircc_irq) < 0) {
 		/* Ignore errors from preconfiguration */
-		IRDA_ERROR("%s, Preconfiguration failed !\n", driver_name);
+		net_err_ratelimited("%s, Preconfiguration failed !\n",
+				    driver_name);
 	}
 #endif
 
 	if (ircc_fir > 0 && ircc_sir > 0) {
-		IRDA_MESSAGE(" Overriding FIR address 0x%04x\n", ircc_fir);
-		IRDA_MESSAGE(" Overriding SIR address 0x%04x\n", ircc_sir);
+		net_info_ratelimited(" Overriding FIR address 0x%04x\n",
+				     ircc_fir);
+		net_info_ratelimited(" Overriding SIR address 0x%04x\n",
+				     ircc_sir);
 
 		if (smsc_ircc_open(ircc_fir, ircc_sir, ircc_dma, ircc_irq))
 			ret = -ENODEV;
@@ -434,8 +437,8 @@ static int __init smsc_ircc_legacy_probe(void)
 
 		/* try user provided configuration register base address */
 		if (ircc_cfg > 0) {
-			IRDA_MESSAGE(" Overriding configuration address "
-				     "0x%04x\n", ircc_cfg);
+			net_info_ratelimited(" Overriding configuration address 0x%04x\n",
+					     ircc_cfg);
 			if (!smsc_superio_fdc(ircc_cfg))
 				ret = 0;
 			if (!smsc_superio_lpc(ircc_cfg))
@@ -462,7 +465,8 @@ static int __init smsc_ircc_init(void)
 
 	ret = platform_driver_register(&smsc_ircc_driver);
 	if (ret) {
-		IRDA_ERROR("%s, Can't register driver!\n", driver_name);
+		net_err_ratelimited("%s, Can't register driver!\n",
+				    driver_name);
 		return ret;
 	}
 
@@ -527,7 +531,7 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 
 	err = -ENOMEM;
 	if (dev_count >= ARRAY_SIZE(dev_self)) {
-	        IRDA_WARNING("%s(), too many devices!\n", __func__);
+		net_warn_ratelimited("%s(), too many devices!\n", __func__);
 		goto err_out1;
 	}
 
@@ -536,7 +540,8 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 	 */
 	dev = alloc_irdadev(sizeof(struct smsc_ircc_cb));
 	if (!dev) {
-		IRDA_WARNING("%s() can't allocate net device\n", __func__);
+		net_warn_ratelimited("%s() can't allocate net device\n",
+				     __func__);
 		goto err_out1;
 	}
 
@@ -588,8 +593,8 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 
 	err = register_netdev(self->netdev);
 	if (err) {
-		IRDA_ERROR("%s, Network device registration failed!\n",
-			   driver_name);
+		net_err_ratelimited("%s, Network device registration failed!\n",
+				    driver_name);
 		goto err_out4;
 	}
 
@@ -601,7 +606,7 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 	}
 	platform_set_drvdata(self->pldev, self);
 
-	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
+	net_info_ratelimited("IrDA: Registered device %s\n", dev->name);
 	dev_count++;
 
 	return 0;
@@ -637,15 +642,15 @@ static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base)
 
 	if (!request_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT,
 			    driver_name)) {
-		IRDA_WARNING("%s: can't get fir_base of 0x%03x\n",
-			     __func__, fir_base);
+		net_warn_ratelimited("%s: can't get fir_base of 0x%03x\n",
+				     __func__, fir_base);
 		goto out1;
 	}
 
 	if (!request_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT,
 			    driver_name)) {
-		IRDA_WARNING("%s: can't get sir_base of 0x%03x\n",
-			     __func__, sir_base);
+		net_warn_ratelimited("%s: can't get sir_base of 0x%03x\n",
+				     __func__, sir_base);
 		goto out2;
 	}
 
@@ -660,13 +665,13 @@ static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base)
 	irq     = (config & IRCC_INTERFACE_IRQ_MASK) >> 4;
 
 	if (high != 0x10 || low != 0xb8 || (chip != 0xf1 && chip != 0xf2)) {
-		IRDA_WARNING("%s(), addr 0x%04x - no device found!\n",
-			     __func__, fir_base);
+		net_warn_ratelimited("%s(), addr 0x%04x - no device found!\n",
+				     __func__, fir_base);
 		goto out3;
 	}
-	IRDA_MESSAGE("SMsC IrDA Controller found\n IrCC version %d.%d, "
-		     "firport 0x%03x, sirport 0x%03x dma=%d, irq=%d\n",
-		     chip & 0x0f, version, fir_base, sir_base, dma, irq);
+	net_info_ratelimited("SMsC IrDA Controller found\n IrCC version %d.%d, firport 0x%03x, sirport 0x%03x dma=%d, irq=%d\n",
+			     chip & 0x0f, version,
+			     fir_base, sir_base, dma, irq);
 
 	return 0;
 
@@ -704,16 +709,16 @@ static void smsc_ircc_setup_io(struct smsc_ircc_cb *self,
 
 	if (irq != IRQ_INVAL) {
 		if (irq != chip_irq)
-			IRDA_MESSAGE("%s, Overriding IRQ - chip says %d, using %d\n",
-				     driver_name, chip_irq, irq);
+			net_info_ratelimited("%s, Overriding IRQ - chip says %d, using %d\n",
+					     driver_name, chip_irq, irq);
 		self->io.irq = irq;
 	} else
 		self->io.irq = chip_irq;
 
 	if (dma != DMA_INVAL) {
 		if (dma != chip_dma)
-			IRDA_MESSAGE("%s, Overriding DMA - chip says %d, using %d\n",
-				     driver_name, chip_dma, dma);
+			net_info_ratelimited("%s, Overriding DMA - chip says %d, using %d\n",
+					     driver_name, chip_dma, dma);
 		self->io.dma = dma;
 	} else
 		self->io.dma = chip_dma;
@@ -852,8 +857,8 @@ static void smsc_ircc_timeout(struct net_device *dev)
 	struct smsc_ircc_cb *self = netdev_priv(dev);
 	unsigned long flags;
 
-	IRDA_WARNING("%s: transmit timed out, changing speed to: %d\n",
-		     dev->name, self->io.speed);
+	net_warn_ratelimited("%s: transmit timed out, changing speed to: %d\n",
+			     dev->name, self->io.speed);
 	spin_lock_irqsave(&self->lock, flags);
 	smsc_ircc_sir_start(self);
 	smsc_ircc_change_speed(self, self->io.speed);
@@ -1442,17 +1447,15 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 	len -= self->io.speed < 4000000 ? 2 : 4;
 
 	if (len < 2 || len > 2050) {
-		IRDA_WARNING("%s(), bogus len=%d\n", __func__, len);
+		net_warn_ratelimited("%s(), bogus len=%d\n", __func__, len);
 		return;
 	}
 	IRDA_DEBUG(2, "%s: msgcnt = %d, len=%d\n", __func__, msgcnt, len);
 
 	skb = dev_alloc_skb(len + 1);
-	if (!skb) {
-		IRDA_WARNING("%s(), memory squeeze, dropping frame.\n",
-			     __func__);
+	if (!skb)
 		return;
-	}
+
 	/* Make sure IP header gets aligned */
 	skb_reserve(skb, 1);
 
@@ -1730,8 +1733,8 @@ static int smsc_ircc_net_open(struct net_device *dev)
 	if (request_dma(self->io.dma, dev->name)) {
 		smsc_ircc_net_close(dev);
 
-		IRDA_WARNING("%s(), unable to allocate DMA=%d\n",
-			     __func__, self->io.dma);
+		net_warn_ratelimited("%s(), unable to allocate DMA=%d\n",
+				     __func__, self->io.dma);
 		return -EAGAIN;
 	}
 
@@ -2019,7 +2022,8 @@ static int smsc_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
 
 	/* Tx FIFO should be empty! */
 	if (!(inb(iobase + UART_LSR) & UART_LSR_THRE)) {
-		IRDA_WARNING("%s(), failed, fifo not empty!\n", __func__);
+		net_warn_ratelimited("%s(), failed, fifo not empty!\n",
+				     __func__);
 		return 0;
 	}
 
@@ -2058,14 +2062,14 @@ static void smsc_ircc_probe_transceiver(struct smsc_ircc_cb *self)
 
 	for (i = 0; smsc_transceivers[i].name != NULL; i++)
 		if (smsc_transceivers[i].probe(self->io.fir_base)) {
-			IRDA_MESSAGE(" %s transceiver found\n",
-				     smsc_transceivers[i].name);
+			net_info_ratelimited(" %s transceiver found\n",
+					     smsc_transceivers[i].name);
 			self->transceiver= i + 1;
 			return;
 		}
 
-	IRDA_MESSAGE("No transceiver found. Defaulting to %s\n",
-		     smsc_transceivers[SMSC_IRCC2_C_DEFAULT_TRANSCEIVER].name);
+	net_info_ratelimited("No transceiver found. Defaulting to %s\n",
+			     smsc_transceivers[SMSC_IRCC2_C_DEFAULT_TRANSCEIVER].name);
 
 	self->transceiver = SMSC_IRCC2_C_DEFAULT_TRANSCEIVER;
 }
@@ -2191,7 +2195,7 @@ static int __init smsc_superio_flat(const struct smsc_chip *chips, unsigned shor
 	/*printk(KERN_WARNING "%s(): mode: 0x%02x\n", __func__, mode);*/
 
 	if (!(mode & SMSCSIOFLAT_UART2MODE_VAL_IRDA))
-		IRDA_WARNING("%s(): IrDA not enabled\n", __func__);
+		net_warn_ratelimited("%s(): IrDA not enabled\n", __func__);
 
 	outb(SMSCSIOFLAT_UART2BASEADDR_REG, cfgbase);
 	sirbase = inb(cfgbase + 1) << 2;
@@ -2208,7 +2212,8 @@ static int __init smsc_superio_flat(const struct smsc_chip *chips, unsigned shor
 	outb(SMSCSIOFLAT_UARTIRQSELECT_REG, cfgbase);
 	irq = inb(cfgbase + 1) & SMSCSIOFLAT_UART2IRQSELECT_MASK;
 
-	IRDA_MESSAGE("%s(): fir: 0x%02x, sir: 0x%02x, dma: %02d, irq: %d, mode: 0x%02x\n", __func__, firbase, sirbase, dma, irq, mode);
+	net_info_ratelimited("%s(): fir: 0x%02x, sir: 0x%02x, dma: %02d, irq: %d, mode: 0x%02x\n",
+			     __func__, firbase, sirbase, dma, irq, mode);
 
 	if (firbase && smsc_ircc_open(firbase, sirbase, dma, irq) == 0)
 		ret = 0;
@@ -2329,16 +2334,16 @@ static const struct smsc_chip * __init smsc_ircc_probe(unsigned short cfg_base,
 			return NULL;
 	}
 
-	IRDA_MESSAGE("found SMC SuperIO Chip (devid=0x%02x rev=%02X base=0x%04x): %s%s\n",
-		     devid, rev, cfg_base, type, chip->name);
+	net_info_ratelimited("found SMC SuperIO Chip (devid=0x%02x rev=%02X base=0x%04x): %s%s\n",
+			     devid, rev, cfg_base, type, chip->name);
 
 	if (chip->rev > rev) {
-		IRDA_MESSAGE("Revision higher than expected\n");
+		net_info_ratelimited("Revision higher than expected\n");
 		return NULL;
 	}
 
 	if (chip->flags & NoIRDA)
-		IRDA_MESSAGE("chipset does not support IRDA\n");
+		net_info_ratelimited("chipset does not support IRDA\n");
 
 	return chip;
 }
@@ -2348,8 +2353,8 @@ static int __init smsc_superio_fdc(unsigned short cfg_base)
 	int ret = -1;
 
 	if (!request_region(cfg_base, 2, driver_name)) {
-		IRDA_WARNING("%s: can't get cfg_base of 0x%03x\n",
-			     __func__, cfg_base);
+		net_warn_ratelimited("%s: can't get cfg_base of 0x%03x\n",
+				     __func__, cfg_base);
 	} else {
 		if (!smsc_superio_flat(fdc_chips_flat, cfg_base, "FDC") ||
 		    !smsc_superio_paged(fdc_chips_paged, cfg_base, "FDC"))
@@ -2366,8 +2371,8 @@ static int __init smsc_superio_lpc(unsigned short cfg_base)
 	int ret = -1;
 
 	if (!request_region(cfg_base, 2, driver_name)) {
-		IRDA_WARNING("%s: can't get cfg_base of 0x%03x\n",
-			     __func__, cfg_base);
+		net_warn_ratelimited("%s: can't get cfg_base of 0x%03x\n",
+				     __func__, cfg_base);
 	} else {
 		if (!smsc_superio_flat(lpc_chips_flat, cfg_base, "LPC") ||
 		    !smsc_superio_paged(lpc_chips_paged, cfg_base, "LPC"))
@@ -2540,8 +2545,8 @@ static int __init preconfigure_smsc_chip(struct
 	outb( (conf->sir_io >> 2), iobase + 1); // bits 2-9 of 0x3f8
 	tmpbyte = inb(iobase + 1);
 	if (tmpbyte != (conf->sir_io >> 2) ) {
-		IRDA_WARNING("ERROR: could not configure SIR ioport.\n");
-		IRDA_WARNING("Try to supply ircc_cfg argument.\n");
+		net_warn_ratelimited("ERROR: could not configure SIR ioport\n");
+		net_warn_ratelimited("Try to supply ircc_cfg argument\n");
 		return -ENXIO;
 	}
 
@@ -2553,7 +2558,7 @@ static int __init preconfigure_smsc_chip(struct
 	outb(tmpbyte, iobase + 1);
 	tmpbyte = inb(iobase + 1) & SMSCSIOFLAT_UART2IRQSELECT_MASK;
 	if (tmpbyte != conf->fir_irq) {
-		IRDA_WARNING("ERROR: could not configure FIR IRQ channel.\n");
+		net_warn_ratelimited("ERROR: could not configure FIR IRQ channel\n");
 		return -ENXIO;
 	}
 
@@ -2562,7 +2567,7 @@ static int __init preconfigure_smsc_chip(struct
 	outb((conf->fir_io >> 3), iobase + 1);
 	tmpbyte = inb(iobase + 1);
 	if (tmpbyte != (conf->fir_io >> 3) ) {
-		IRDA_WARNING("ERROR: could not configure FIR I/O port.\n");
+		net_warn_ratelimited("ERROR: could not configure FIR I/O port\n");
 		return -ENXIO;
 	}
 
@@ -2571,7 +2576,7 @@ static int __init preconfigure_smsc_chip(struct
 	outb((conf->fir_dma & LPC47N227_FIRDMASELECT_MASK), iobase + 1); // DMA
 	tmpbyte = inb(iobase + 1) & LPC47N227_FIRDMASELECT_MASK;
 	if (tmpbyte != (conf->fir_dma & LPC47N227_FIRDMASELECT_MASK)) {
-		IRDA_WARNING("ERROR: could not configure FIR DMA channel.\n");
+		net_warn_ratelimited("ERROR: could not configure FIR DMA channel\n");
 		return -ENXIO;
 	}
 
@@ -2628,7 +2633,7 @@ static int __init preconfigure_through_82801(struct pci_dev *dev,
 	unsigned short tmpword;
 	unsigned char tmpbyte;
 
-	IRDA_MESSAGE("Setting up Intel 82801 controller and SMSC device\n");
+	net_info_ratelimited("Setting up Intel 82801 controller and SMSC device\n");
 	/*
 	 * Select the range for the COMA COM port (SIR)
 	 * Register COM_DEC:
@@ -2699,8 +2704,8 @@ static int __init preconfigure_through_82801(struct pci_dev *dev,
 		tmpword |= 0x0400;
 		break;
 	default:
-		IRDA_WARNING("Uncommon I/O base address: 0x%04x\n",
-			     conf->cfg_base);
+		net_warn_ratelimited("Uncommon I/O base address: 0x%04x\n",
+				     conf->cfg_base);
 		break;
 	}
 	tmpword &= 0xfffd; /* disable LPC COMB */
@@ -2800,7 +2805,8 @@ static void __init preconfigure_ali_port(struct pci_dev *dev,
 		mask = 0x08;
 		break;
 	default:
-		IRDA_ERROR("Failed to configure unsupported port on ALi 1533 bridge: 0x%04x\n", port);
+		net_err_ratelimited("Failed to configure unsupported port on ALi 1533 bridge: 0x%04x\n",
+				    port);
 		return;
 	}
 
@@ -2808,7 +2814,8 @@ static void __init preconfigure_ali_port(struct pci_dev *dev,
 	/* Turn on the right bits */
 	tmpbyte |= mask;
 	pci_write_config_byte(dev, reg, tmpbyte);
-	IRDA_MESSAGE("Activated ALi 1533 ISA bridge port 0x%04x.\n", port);
+	net_info_ratelimited("Activated ALi 1533 ISA bridge port 0x%04x\n",
+			     port);
 }
 
 static int __init preconfigure_through_ali(struct pci_dev *dev,
@@ -2877,7 +2884,8 @@ static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg,
 				if (ircc_irq != IRQ_INVAL)
 					tmpconf.fir_irq = ircc_irq;
 
-				IRDA_MESSAGE("Detected unconfigured %s SMSC IrDA chip, pre-configuring device.\n", conf->name);
+				net_info_ratelimited("Detected unconfigured %s SMSC IrDA chip, pre-configuring device\n",
+						     conf->name);
 				if (conf->preconfigure)
 					ret = conf->preconfigure(dev, &tmpconf);
 				else
@@ -2922,8 +2930,8 @@ static void smsc_ircc_set_transceiver_smsc_ircc_atc(int fir_base, u32 speed)
 		/* empty */;
 
 	if (val)
-		IRDA_WARNING("%s(): ATC: 0x%02x\n", __func__,
-			     inb(fir_base + IRCC_ATC));
+		net_warn_ratelimited("%s(): ATC: 0x%02x\n",
+				     __func__, inb(fir_base + IRCC_ATC));
 }
 
 /*
diff --git a/drivers/net/irda/tekram-sir.c b/drivers/net/irda/tekram-sir.c
index 048a154..04db4ea 100644
--- a/drivers/net/irda/tekram-sir.c
+++ b/drivers/net/irda/tekram-sir.c
@@ -179,7 +179,8 @@ static int tekram_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		IRDA_ERROR("%s - undefined state %d\n", __func__, state);
+		net_err_ratelimited("%s - undefined state %d\n",
+				    __func__, state);
 		ret = -EINVAL;
 		break;
 	}
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 36e0042..b07b4cc 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -391,7 +391,8 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 	if (err)
 		goto err_out4;
 
-	IRDA_MESSAGE("IrDA: Registered device %s (via-ircc)\n", dev->name);
+	net_info_ratelimited("IrDA: Registered device %s (via-ircc)\n",
+			     dev->name);
 
 	/* Initialise the hardware..
 	*/
@@ -510,7 +511,7 @@ static void via_hw_init(struct via_ircc_cb *self)
  */
 static int via_ircc_read_dongle_id(int iobase)
 {
-	IRDA_ERROR("via-ircc: dongle probing not supported, please specify dongle_id module parameter.\n");
+	net_err_ratelimited("via-ircc: dongle probing not supported, please specify dongle_id module parameter\n");
 	return 9;	/* Default to IBM */
 }
 
@@ -652,8 +653,8 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 		break;
 
 	default:
-		IRDA_ERROR("%s: Error: dongle_id %d unsupported !\n",
-			   __func__, dongle_id);
+		net_err_ratelimited("%s: Error: dongle_id %d unsupported !\n",
+				    __func__, dongle_id);
 	}
 }
 
@@ -1473,8 +1474,8 @@ static int via_ircc_net_open(struct net_device *dev)
 	IRDA_ASSERT(self != NULL, return 0;);
 	iobase = self->io.fir_base;
 	if (request_irq(self->io.irq, via_ircc_interrupt, 0, dev->name, dev)) {
-		IRDA_WARNING("%s, unable to allocate irq=%d\n", driver_name,
-			     self->io.irq);
+		net_warn_ratelimited("%s, unable to allocate irq=%d\n",
+				     driver_name, self->io.irq);
 		return -EAGAIN;
 	}
 	/*
@@ -1482,15 +1483,15 @@ static int via_ircc_net_open(struct net_device *dev)
 	 * failure.
 	 */
 	if (request_dma(self->io.dma, dev->name)) {
-		IRDA_WARNING("%s, unable to allocate dma=%d\n", driver_name,
-			     self->io.dma);
+		net_warn_ratelimited("%s, unable to allocate dma=%d\n",
+				     driver_name, self->io.dma);
 		free_irq(self->io.irq, dev);
 		return -EAGAIN;
 	}
 	if (self->io.dma2 != self->io.dma) {
 		if (request_dma(self->io.dma2, dev->name)) {
-			IRDA_WARNING("%s, unable to allocate dma2=%d\n",
-				     driver_name, self->io.dma2);
+			net_warn_ratelimited("%s, unable to allocate dma2=%d\n",
+					     driver_name, self->io.dma2);
 			free_irq(self->io.irq, dev);
 			free_dma(self->io.dma);
 			return -EAGAIN;
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index a2e5561..fd4dede 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -429,8 +429,8 @@ static struct vlsi_ring *vlsi_alloc_ring(struct pci_dev *pdev, struct ring_descr
 		if (rd->buf == NULL ||
 		    !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
 			if (rd->buf) {
-				IRDA_ERROR("%s: failed to create PCI-MAP for %p",
-					   __func__, rd->buf);
+				net_err_ratelimited("%s: failed to create PCI-MAP for %p\n",
+						    __func__, rd->buf);
 				kfree(rd->buf);
 				rd->buf = NULL;
 			}
@@ -483,11 +483,8 @@ static int vlsi_create_hwif(vlsi_irda_dev_t *idev)
 
 	ringarea = pci_zalloc_consistent(idev->pdev, HW_RING_AREA_SIZE,
 					 &idev->busaddr);
-	if (!ringarea) {
-		IRDA_ERROR("%s: insufficient memory for descriptor rings\n",
-			   __func__);
+	if (!ringarea)
 		goto out;
-	}
 
 	hwmap = (struct ring_descr_hw *)ringarea;
 	idev->rx_ring = vlsi_alloc_ring(idev->pdev, hwmap, ringsize[1],
@@ -581,7 +578,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 	}
 
 	if (!rd->skb) {
-		IRDA_WARNING("%s: rx packet lost\n", __func__);
+		net_warn_ratelimited("%s: rx packet lost\n", __func__);
 		ret |= VLSI_RX_DROP;
 		goto done;
 	}
@@ -610,8 +607,8 @@ static void vlsi_fill_rx(struct vlsi_ring *r)
 
 	for (rd = ring_last(r); rd != NULL; rd = ring_put(r)) {
 		if (rd_is_active(rd)) {
-			IRDA_WARNING("%s: driver bug: rx descr race with hw\n",
-				     __func__);
+			net_warn_ratelimited("%s: driver bug: rx descr race with hw\n",
+					     __func__);
 			vlsi_ring_debug(r);
 			break;
 		}
@@ -670,7 +667,7 @@ static void vlsi_rx_interrupt(struct net_device *ndev)
 
 	if (ring_first(r) == NULL) {
 		/* we are in big trouble, if this should ever happen */
-		IRDA_ERROR("%s: rx ring exhausted!\n", __func__);
+		net_err_ratelimited("%s: rx ring exhausted!\n", __func__);
 		vlsi_ring_debug(r);
 	}
 	else
@@ -783,8 +780,8 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 		config = IRCFG_SIR | IRCFG_SIRFILT  | IRCFG_RXANY;
 		switch(baudrate) {
 			default:
-				IRDA_WARNING("%s: undefined baudrate %d - fallback to 9600!\n",
-					     __func__, baudrate);
+				net_warn_ratelimited("%s: undefined baudrate %d - fallback to 9600!\n",
+						     __func__, baudrate);
 				baudrate = 9600;
 				/* fallthru */
 			case 2400:
@@ -825,14 +822,16 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 		config ^= IRENABLE_SIR_ON;
 
 	if (config != (IRENABLE_PHYANDCLOCK|IRENABLE_ENRXST)) {
-		IRDA_WARNING("%s: failed to set %s mode!\n", __func__,
-			(mode==IFF_SIR)?"SIR":((mode==IFF_MIR)?"MIR":"FIR"));
+		net_warn_ratelimited("%s: failed to set %s mode!\n",
+				     __func__,
+				     mode == IFF_SIR ? "SIR" :
+				     mode == IFF_MIR ? "MIR" : "FIR");
 		ret = -1;
 	}
 	else {
 		if (inw(iobase+VLSI_PIO_PHYCTL) != nphyctl) {
-			IRDA_WARNING("%s: failed to apply baudrate %d\n",
-				     __func__, baudrate);
+			net_warn_ratelimited("%s: failed to apply baudrate %d\n",
+					     __func__, baudrate);
 			ret = -1;
 		}
 		else {
@@ -977,8 +976,8 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 		 */
 
 		if (len >= r->len-5)
-			 IRDA_WARNING("%s: possible buffer overflow with SIR wrapping!\n",
-				      __func__);
+			net_warn_ratelimited("%s: possible buffer overflow with SIR wrapping!\n",
+					     __func__);
 	}
 	else {
 		/* hw deals with MIR/FIR mode wrapping */
@@ -1044,7 +1043,7 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 drop_unlock:
 	spin_unlock_irqrestore(&idev->lock, flags);
 drop:
-	IRDA_WARNING("%s: dropping packet - %s\n", __func__, msg);
+	net_warn_ratelimited("%s: dropping packet - %s\n", __func__, msg);
 	dev_kfree_skb_any(skb);
 	ndev->stats.tx_errors++;
 	ndev->stats.tx_dropped++;
@@ -1183,8 +1182,8 @@ static int vlsi_start_clock(struct pci_dev *pdev)
 		}
 		if (count < 3) {
 			if (clksrc == 1) { /* explicitly asked for PLL hence bail out */
-				IRDA_ERROR("%s: no PLL or failed to lock!\n",
-					   __func__);
+				net_err_ratelimited("%s: no PLL or failed to lock!\n",
+						    __func__);
 				clkctl = CLKCTL_CLKSTP;
 				pci_write_config_byte(pdev, VLSI_PCI_CLKCTL, clkctl);
 				return -1;
@@ -1265,7 +1264,7 @@ static int vlsi_init_chip(struct pci_dev *pdev)
 	/* start the clock and clean the registers */
 
 	if (vlsi_start_clock(pdev)) {
-		IRDA_ERROR("%s: no valid clock source\n", __func__);
+		net_err_ratelimited("%s: no valid clock source\n", __func__);
 		return -1;
 	}
 	iobase = ndev->base_addr;
@@ -1389,8 +1388,8 @@ static void vlsi_tx_timeout(struct net_device *ndev)
 		idev->new_baud = idev->baud;		/* keep current baudrate */
 
 	if (vlsi_start_hw(idev))
-		IRDA_ERROR("%s: failed to restart hw - %s(%s) unusable!\n",
-			   __func__, pci_name(idev->pdev), ndev->name);
+		net_err_ratelimited("%s: failed to restart hw - %s(%s) unusable!\n",
+				    __func__, pci_name(idev->pdev), ndev->name);
 	else
 		netif_start_queue(ndev);
 }
@@ -1434,8 +1433,8 @@ static int vlsi_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 			irq->ifr_receiving = (fifocnt!=0) ? 1 : 0;
 			break;
 		default:
-			IRDA_WARNING("%s: notsupp - cmd=%04x\n",
-				     __func__, cmd);
+			net_warn_ratelimited("%s: notsupp - cmd=%04x\n",
+					     __func__, cmd);
 			ret = -EOPNOTSUPP;
 	}	
 	
@@ -1479,8 +1478,8 @@ static irqreturn_t vlsi_interrupt(int irq, void *dev_instance)
 	spin_unlock_irqrestore(&idev->lock,flags);
 
 	if (boguscount <= 0)
-		IRDA_MESSAGE("%s: too much work in interrupt!\n",
-			     __func__);
+		net_info_ratelimited("%s: too much work in interrupt!\n",
+				     __func__);
 	return IRQ_RETVAL(handled);
 }
 
@@ -1493,7 +1492,7 @@ static int vlsi_open(struct net_device *ndev)
 	char	hwname[32];
 
 	if (pci_request_regions(idev->pdev, drivername)) {
-		IRDA_WARNING("%s: io resource busy\n", __func__);
+		net_warn_ratelimited("%s: io resource busy\n", __func__);
 		goto errout;
 	}
 	ndev->base_addr = pci_resource_start(idev->pdev,0);
@@ -1507,8 +1506,8 @@ static int vlsi_open(struct net_device *ndev)
 
 	if (request_irq(ndev->irq, vlsi_interrupt, IRQF_SHARED,
 			drivername, ndev)) {
-		IRDA_WARNING("%s: couldn't get IRQ: %d\n",
-			     __func__, ndev->irq);
+		net_warn_ratelimited("%s: couldn't get IRQ: %d\n",
+				     __func__, ndev->irq);
 		goto errout_io;
 	}
 
@@ -1529,7 +1528,8 @@ static int vlsi_open(struct net_device *ndev)
 
 	netif_start_queue(ndev);
 
-	IRDA_MESSAGE("%s: device %s operational\n", __func__, ndev->name);
+	net_info_ratelimited("%s: device %s operational\n",
+			     __func__, ndev->name);
 
 	return 0;
 
@@ -1563,7 +1563,7 @@ static int vlsi_close(struct net_device *ndev)
 
 	pci_release_regions(idev->pdev);
 
-	IRDA_MESSAGE("%s: device %s stopped\n", __func__, ndev->name);
+	net_info_ratelimited("%s: device %s stopped\n", __func__, ndev->name);
 
 	return 0;
 }
@@ -1590,7 +1590,8 @@ static int vlsi_irda_init(struct net_device *ndev)
 
 	if (pci_set_dma_mask(pdev,DMA_MASK_USED_BY_HW) ||
 	    pci_set_dma_mask(pdev,DMA_MASK_MSTRPAGE)) {
-		IRDA_ERROR("%s: aborting due to PCI BM-DMA address limitations\n", __func__);
+		net_err_ratelimited("%s: aborting due to PCI BM-DMA address limitations\n",
+				    __func__);
 		return -1;
 	}
 
@@ -1632,19 +1633,19 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	else
 		pdev->current_state = 0; /* hw must be running now */
 
-	IRDA_MESSAGE("%s: IrDA PCI controller %s detected\n",
-		     drivername, pci_name(pdev));
+	net_info_ratelimited("%s: IrDA PCI controller %s detected\n",
+			     drivername, pci_name(pdev));
 
 	if ( !pci_resource_start(pdev,0) ||
 	     !(pci_resource_flags(pdev,0) & IORESOURCE_IO) ) {
-		IRDA_ERROR("%s: bar 0 invalid", __func__);
+		net_err_ratelimited("%s: bar 0 invalid", __func__);
 		goto out_disable;
 	}
 
 	ndev = alloc_irdadev(sizeof(*idev));
 	if (ndev==NULL) {
-		IRDA_ERROR("%s: Unable to allocate device memory.\n",
-			   __func__);
+		net_err_ratelimited("%s: Unable to allocate device memory.\n",
+				    __func__);
 		goto out_disable;
 	}
 
@@ -1659,7 +1660,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_freedev;
 
 	if (register_netdev(ndev) < 0) {
-		IRDA_ERROR("%s: register_netdev failed\n", __func__);
+		net_err_ratelimited("%s: register_netdev failed\n", __func__);
 		goto out_freedev;
 	}
 
@@ -1669,14 +1670,15 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		ent = proc_create_data(ndev->name, S_IFREG|S_IRUGO,
 				       vlsi_proc_root, VLSI_PROC_FOPS, ndev);
 		if (!ent) {
-			IRDA_WARNING("%s: failed to create proc entry\n",
-				     __func__);
+			net_warn_ratelimited("%s: failed to create proc entry\n",
+					     __func__);
 		} else {
 			proc_set_size(ent, 0);
 		}
 		idev->proc_entry = ent;
 	}
-	IRDA_MESSAGE("%s: registered device %s\n", drivername, ndev->name);
+	net_info_ratelimited("%s: registered device %s\n",
+			     drivername, ndev->name);
 
 	pci_set_drvdata(pdev, ndev);
 	mutex_unlock(&idev->mtx);
@@ -1698,7 +1700,7 @@ static void vlsi_irda_remove(struct pci_dev *pdev)
 	vlsi_irda_dev_t *idev;
 
 	if (!ndev) {
-		IRDA_ERROR("%s: lost netdevice?\n", drivername);
+		net_err_ratelimited("%s: lost netdevice?\n", drivername);
 		return;
 	}
 
@@ -1714,7 +1716,7 @@ static void vlsi_irda_remove(struct pci_dev *pdev)
 
 	free_netdev(ndev);
 
-	IRDA_MESSAGE("%s: %s removed\n", drivername, pci_name(pdev));
+	net_info_ratelimited("%s: %s removed\n", drivername, pci_name(pdev));
 }
 
 #ifdef CONFIG_PM
@@ -1733,8 +1735,8 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 	vlsi_irda_dev_t *idev;
 
 	if (!ndev) {
-		IRDA_ERROR("%s - %s: no netdevice\n",
-			   __func__, pci_name(pdev));
+		net_err_ratelimited("%s - %s: no netdevice\n",
+				    __func__, pci_name(pdev));
 		return 0;
 	}
 	idev = netdev_priv(ndev);
@@ -1745,7 +1747,9 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 			pdev->current_state = state.event;
 		}
 		else
-			IRDA_ERROR("%s - %s: invalid suspend request %u -> %u\n", __func__, pci_name(pdev), pdev->current_state, state.event);
+			net_err_ratelimited("%s - %s: invalid suspend request %u -> %u\n",
+					    __func__, pci_name(pdev),
+					    pdev->current_state, state.event);
 		mutex_unlock(&idev->mtx);
 		return 0;
 	}
@@ -1772,16 +1776,16 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 	vlsi_irda_dev_t	*idev;
 
 	if (!ndev) {
-		IRDA_ERROR("%s - %s: no netdevice\n",
-			   __func__, pci_name(pdev));
+		net_err_ratelimited("%s - %s: no netdevice\n",
+				    __func__, pci_name(pdev));
 		return 0;
 	}
 	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (pdev->current_state == 0) {
 		mutex_unlock(&idev->mtx);
-		IRDA_WARNING("%s - %s: already resumed\n",
-			     __func__, pci_name(pdev));
+		net_warn_ratelimited("%s - %s: already resumed\n",
+				     __func__, pci_name(pdev));
 		return 0;
 	}
 	
@@ -1800,7 +1804,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 		 * now we explicitly set pdev->current_state = 0 after enabling the
 		 * device and independently resume_ok should catch any garbage config.
 		 */
-		IRDA_WARNING("%s - hm, nothing to resume?\n", __func__);
+		net_warn_ratelimited("%s - hm, nothing to resume?\n", __func__);
 		mutex_unlock(&idev->mtx);
 		return 0;
 	}
@@ -1837,7 +1841,8 @@ static int __init vlsi_mod_init(void)
 	int	i, ret;
 
 	if (clksrc < 0  ||  clksrc > 3) {
-		IRDA_ERROR("%s: invalid clksrc=%d\n", drivername, clksrc);
+		net_err_ratelimited("%s: invalid clksrc=%d\n",
+				    drivername, clksrc);
 		return -1;
 	}
 
@@ -1850,7 +1855,10 @@ static int __init vlsi_mod_init(void)
 			case 64:
 				break;
 			default:
-				IRDA_WARNING("%s: invalid %s ringsize %d, using default=8", drivername, (i)?"rx":"tx", ringsize[i]);
+				net_warn_ratelimited("%s: invalid %s ringsize %d, using default=8\n",
+						     drivername,
+						     i ? "rx" : "tx",
+						     ringsize[i]);
 				ringsize[i] = 8;
 				break;
 		}
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index 5639920..f9119c6 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -615,7 +615,8 @@ static inline void rd_set_addr_status(struct ring_descr *rd, dma_addr_t a, u8 s)
 	 */
 
 	if ((a & ~DMA_MASK_MSTRPAGE)>>24 != MSTRPAGE_VALUE) {
-		IRDA_ERROR("%s: pci busaddr inconsistency!\n", __func__);
+		net_err_ratelimited("%s: pci busaddr inconsistency!\n",
+				    __func__);
 		dump_stack();
 		return;
 	}
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 11dbdf3..86ca123 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -236,10 +236,11 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdevice() failed!\n", __func__);
+		net_err_ratelimited("%s(), register_netdevice() failed!\n",
+				    __func__);
 		goto err_out3;
 	}
-	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
+	net_info_ratelimited("IrDA: Registered device %s\n", dev->name);
 
 	/* Need to store self somewhere */
 	dev_self[i] = self;
@@ -392,8 +393,8 @@ static int w83977af_probe(int iobase, int irq, int dma)
 			switch_bank(iobase, SET7);
 			outb(0x40, iobase+7);
 			
-			IRDA_MESSAGE("W83977AF (IR) driver loaded. "
-				     "Version: 0x%02x\n", version);
+			net_info_ratelimited("W83977AF (IR) driver loaded. Version: 0x%02x\n",
+					     version);
 			
 			return 0;
 		} else {
diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index 42aa054..4ff18bd 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -77,10 +77,6 @@ do { if(!(expr)) { \
 #define IRDA_ASSERT_LABEL(label)
 #endif /* CONFIG_IRDA_DEBUG */
 
-#define IRDA_ERROR		net_err_ratelimited
-#define IRDA_WARNING		net_warn_ratelimited
-#define IRDA_MESSAGE		net_info_ratelimited
-
 /*
  *  Magic numbers used by Linux-IrDA. Random numbers which must be unique to 
  *  give the best protection
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 980bc26..4b04ae0 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -201,16 +201,16 @@ static void irda_connect_confirm(void *instance, void *sap,
 	switch (sk->sk_type) {
 	case SOCK_STREAM:
 		if (max_sdu_size != 0) {
-			IRDA_ERROR("%s: max_sdu_size must be 0\n",
-				   __func__);
+			net_err_ratelimited("%s: max_sdu_size must be 0\n",
+					    __func__);
 			return;
 		}
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
 		break;
 	case SOCK_SEQPACKET:
 		if (max_sdu_size == 0) {
-			IRDA_ERROR("%s: max_sdu_size cannot be 0\n",
-				   __func__);
+			net_err_ratelimited("%s: max_sdu_size cannot be 0\n",
+					    __func__);
 			return;
 		}
 		self->max_data_size = max_sdu_size;
@@ -262,8 +262,8 @@ static void irda_connect_indication(void *instance, void *sap,
 	switch (sk->sk_type) {
 	case SOCK_STREAM:
 		if (max_sdu_size != 0) {
-			IRDA_ERROR("%s: max_sdu_size must be 0\n",
-				   __func__);
+			net_err_ratelimited("%s: max_sdu_size must be 0\n",
+					    __func__);
 			kfree_skb(skb);
 			return;
 		}
@@ -271,8 +271,8 @@ static void irda_connect_indication(void *instance, void *sap,
 		break;
 	case SOCK_SEQPACKET:
 		if (max_sdu_size == 0) {
-			IRDA_ERROR("%s: max_sdu_size cannot be 0\n",
-				   __func__);
+			net_err_ratelimited("%s: max_sdu_size cannot be 0\n",
+					    __func__);
 			kfree_skb(skb);
 			return;
 		}
@@ -368,7 +368,7 @@ static void irda_getvalue_confirm(int result, __u16 obj_id,
 
 	self = priv;
 	if (!self) {
-		IRDA_WARNING("%s: lost myself!\n", __func__);
+		net_warn_ratelimited("%s: lost myself!\n", __func__);
 		return;
 	}
 
@@ -417,7 +417,7 @@ static void irda_selective_discovery_indication(discinfo_t *discovery,
 
 	self = priv;
 	if (!self) {
-		IRDA_WARNING("%s: lost myself!\n", __func__);
+		net_warn_ratelimited("%s: lost myself!\n", __func__);
 		return;
 	}
 
@@ -505,7 +505,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
 	notify_t notify;
 
 	if (self->lsap) {
-		IRDA_WARNING("%s(), busy!\n", __func__);
+		net_warn_ratelimited("%s(), busy!\n", __func__);
 		return -EBUSY;
 	}
 
@@ -541,8 +541,8 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 	IRDA_DEBUG(2, "%s(%p, %s)\n", __func__, self, name);
 
 	if (self->iriap) {
-		IRDA_WARNING("%s(): busy with a previous query\n",
-			     __func__);
+		net_warn_ratelimited("%s(): busy with a previous query\n",
+				     __func__);
 		return -EBUSY;
 	}
 
@@ -2129,8 +2129,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 				   __func__, opt);
 			self->max_sdu_size_rx = opt;
 		} else {
-			IRDA_WARNING("%s: not allowed to set MAXSDUSIZE for this socket type!\n",
-				     __func__);
+			net_warn_ratelimited("%s: not allowed to set MAXSDUSIZE for this socket type!\n",
+					     __func__);
 			err = -ENOPROTOOPT;
 			goto out;
 		}
@@ -2441,8 +2441,8 @@ bed:
 
 		/* Check that we can proceed with IAP */
 		if (self->iriap) {
-			IRDA_WARNING("%s: busy with a previous query\n",
-				     __func__);
+			net_warn_ratelimited("%s: busy with a previous query\n",
+					     __func__);
 			kfree(ias_opt);
 			err = -EBUSY;
 			goto out;
diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index 4490a67..b77fe8c 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -69,7 +69,8 @@ static int __init ircomm_init(void)
 {
 	ircomm = hashbin_new(HB_LOCK);
 	if (ircomm == NULL) {
-		IRDA_ERROR("%s(), can't allocate hashbin!\n", __func__);
+		net_err_ratelimited("%s(), can't allocate hashbin!\n",
+				    __func__);
 		return -ENOMEM;
 	}
 
@@ -83,7 +84,7 @@ static int __init ircomm_init(void)
 	}
 #endif /* CONFIG_PROC_FS */
 
-	IRDA_MESSAGE("IrCOMM protocol (Dag Brattli)\n");
+	net_info_ratelimited("IrCOMM protocol (Dag Brattli)\n");
 
 	return 0;
 }
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 6536114..05767e3 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -204,7 +204,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 	}
 	ret = irlmp_data_request(self->lsap, skb);
 	if (ret) {
-		IRDA_ERROR("%s(), failed\n", __func__);
+		net_err_ratelimited("%s(), failed\n", __func__);
 		/* irlmp_data_request already free the packet */
 	}
 
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index f80b1a6..c203fbb 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -130,7 +130,8 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 	count = irda_param_insert(self, pi, skb_tail_pointer(skb),
 				  skb_tailroom(skb), &ircomm_param_info);
 	if (count < 0) {
-		IRDA_WARNING("%s(), no room for parameter!\n", __func__);
+		net_warn_ratelimited("%s(), no room for parameter!\n",
+				     __func__);
 		spin_unlock_irqrestore(&self->spinlock, flags);
 		return -1;
 	}
diff --git a/net/irda/ircomm/ircomm_ttp.c b/net/irda/ircomm/ircomm_ttp.c
index d362d71..abe9a5a 100644
--- a/net/irda/ircomm/ircomm_ttp.c
+++ b/net/irda/ircomm/ircomm_ttp.c
@@ -188,7 +188,7 @@ static int ircomm_ttp_data_request(struct ircomm_cb *self,
 
 	ret = irttp_data_request(self->tsap, skb);
 	if (ret) {
-		IRDA_ERROR("%s(), failed\n", __func__);
+		net_err_ratelimited("%s(), failed\n", __func__);
 		/* irttp_data_request already free the packet */
 	}
 
@@ -237,8 +237,8 @@ static void ircomm_ttp_connect_confirm(void *instance, void *sap,
 	IRDA_ASSERT(qos != NULL, goto out;);
 
 	if (max_sdu_size != TTP_SAR_DISABLE) {
-		IRDA_ERROR("%s(), SAR not allowed for IrCOMM!\n",
-			   __func__);
+		net_err_ratelimited("%s(), SAR not allowed for IrCOMM!\n",
+				    __func__);
 		goto out;
 	}
 
@@ -278,8 +278,8 @@ static void ircomm_ttp_connect_indication(void *instance, void *sap,
 	IRDA_ASSERT(qos != NULL, goto out;);
 
 	if (max_sdu_size != TTP_SAR_DISABLE) {
-		IRDA_ERROR("%s(), SAR not allowed for IrCOMM!\n",
-			   __func__);
+		net_err_ratelimited("%s(), SAR not allowed for IrCOMM!\n",
+				    __func__);
 		goto out;
 	}
 
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 61ceb4c..11b0a5e 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -147,7 +147,8 @@ static int __init ircomm_tty_init(void)
 		return -ENOMEM;
 	ircomm_tty = hashbin_new(HB_LOCK);
 	if (ircomm_tty == NULL) {
-		IRDA_ERROR("%s(), can't allocate hashbin!\n", __func__);
+		net_err_ratelimited("%s(), can't allocate hashbin!\n",
+				    __func__);
 		put_tty_driver(driver);
 		return -ENOMEM;
 	}
@@ -163,8 +164,8 @@ static int __init ircomm_tty_init(void)
 	driver->flags           = TTY_DRIVER_REAL_RAW;
 	tty_set_operations(driver, &ops);
 	if (tty_register_driver(driver)) {
-		IRDA_ERROR("%s(): Couldn't register serial driver\n",
-			   __func__);
+		net_err_ratelimited("%s(): Couldn't register serial driver\n",
+				    __func__);
 		put_tty_driver(driver);
 		return -1;
 	}
@@ -199,8 +200,8 @@ static void __exit ircomm_tty_cleanup(void)
 
 	ret = tty_unregister_driver(driver);
 	if (ret) {
-		IRDA_ERROR("%s(), failed to unregister driver\n",
-			   __func__);
+		net_err_ratelimited("%s(), failed to unregister driver\n",
+				    __func__);
 		return;
 	}
 
@@ -256,7 +257,7 @@ static int ircomm_tty_startup(struct ircomm_tty_cb *self)
 	/* Connect IrCOMM link with remote device */
 	ret = ircomm_tty_attach_cable(self);
 	if (ret < 0) {
-		IRDA_ERROR("%s(), error attaching cable!\n", __func__);
+		net_err_ratelimited("%s(), error attaching cable!\n", __func__);
 		goto err;
 	}
 
@@ -389,10 +390,8 @@ static int ircomm_tty_install(struct tty_driver *driver, struct tty_struct *tty)
 	if (!self) {
 		/* No, so make new instance */
 		self = kzalloc(sizeof(struct ircomm_tty_cb), GFP_KERNEL);
-		if (self == NULL) {
-			IRDA_ERROR("%s(), kmalloc failed!\n", __func__);
+		if (self == NULL)
 			return -ENOMEM;
-		}
 
 		tty_port_init(&self->port);
 		self->port.ops = &ircomm_port_ops;
@@ -469,8 +468,8 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 
 		if (wait_event_interruptible(self->port.close_wait,
 				!test_bit(ASYNCB_CLOSING, &self->port.flags))) {
-			IRDA_WARNING("%s - got signal while blocking on ASYNC_CLOSING!\n",
-				     __func__);
+			net_warn_ratelimited("%s - got signal while blocking on ASYNC_CLOSING!\n",
+					     __func__);
 			return -ERESTARTSYS;
 		}
 
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 2ee87bf..2119044 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -694,8 +694,8 @@ static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 		self->saddr = info->saddr;
 
 		if (self->iriap) {
-			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __func__);
+			net_warn_ratelimited("%s(), busy with a previous query\n",
+					     __func__);
 			return -EBUSY;
 		}
 
@@ -752,8 +752,8 @@ static int ircomm_tty_state_search(struct ircomm_tty_cb *self,
 		self->saddr = info->saddr;
 
 		if (self->iriap) {
-			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __func__);
+			net_warn_ratelimited("%s(), busy with a previous query\n",
+					     __func__);
 			return -EBUSY;
 		}
 
@@ -822,8 +822,8 @@ static int ircomm_tty_state_query_parameters(struct ircomm_tty_cb *self,
 	switch (event) {
 	case IRCOMM_TTY_GOT_PARAMETERS:
 		if (self->iriap) {
-			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __func__);
+			net_warn_ratelimited("%s(), busy with a previous query\n",
+					     __func__);
 			return -EBUSY;
 		}
 
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index ce94385..7eb06e0 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -93,7 +93,8 @@ static void ircomm_tty_change_speed(struct ircomm_tty_cb *self,
 		self->settings.flow_control |= IRCOMM_RTS_CTS_IN;
 		/* This got me. Bummer. Jean II */
 		if (self->service_type == IRCOMM_3_WIRE_RAW)
-			IRDA_WARNING("%s(), enabling RTS/CTS on link that doesn't support it (3-wire-raw)\n", __func__);
+			net_warn_ratelimited("%s(), enabling RTS/CTS on link that doesn't support it (3-wire-raw)\n",
+					     __func__);
 	} else {
 		self->port.flags &= ~ASYNC_CTS_FLOW;
 		self->settings.flow_control &= ~IRCOMM_RTS_CTS_IN;
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 9e0d909..96788db 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -63,14 +63,14 @@ int __init irda_device_init( void)
 {
 	dongles = hashbin_new(HB_NOLOCK);
 	if (dongles == NULL) {
-		IRDA_WARNING("IrDA: Can't allocate dongles hashbin!\n");
+		net_warn_ratelimited("IrDA: Can't allocate dongles hashbin!\n");
 		return -ENOMEM;
 	}
 	spin_lock_init(&dongles->hb_spinlock);
 
 	tasks = hashbin_new(HB_LOCK);
 	if (tasks == NULL) {
-		IRDA_WARNING("IrDA: Can't allocate tasks hashbin!\n");
+		net_warn_ratelimited("IrDA: Can't allocate tasks hashbin!\n");
 		hashbin_delete(dongles, NULL);
 		return -ENOMEM;
 	}
@@ -84,8 +84,8 @@ int __init irda_device_init( void)
 static void leftover_dongle(void *arg)
 {
 	struct dongle_reg *reg = arg;
-	IRDA_WARNING("IrDA: Dongle type %x not unregistered\n",
-		     reg->type);
+	net_warn_ratelimited("IrDA: Dongle type %x not unregistered\n",
+			     reg->type);
 }
 
 void irda_device_cleanup(void)
@@ -150,8 +150,8 @@ int irda_device_is_receiving(struct net_device *dev)
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (!dev->netdev_ops->ndo_do_ioctl) {
-		IRDA_ERROR("%s: do_ioctl not impl. by device driver\n",
-			   __func__);
+		net_err_ratelimited("%s: do_ioctl not impl. by device driver\n",
+				    __func__);
 		return -1;
 	}
 
@@ -201,15 +201,15 @@ static int irda_task_kick(struct irda_task *task)
 	do {
 		timeout = task->function(task);
 		if (count++ > 100) {
-			IRDA_ERROR("%s: error in task handler!\n",
-				   __func__);
+			net_err_ratelimited("%s: error in task handler!\n",
+					    __func__);
 			irda_task_delete(task);
 			return TRUE;
 		}
 	} while ((timeout == 0) && (task->state != IRDA_TASK_DONE));
 
 	if (timeout < 0) {
-		IRDA_ERROR("%s: Error executing task!\n", __func__);
+		net_err_ratelimited("%s: Error executing task!\n", __func__);
 		irda_task_delete(task);
 		return TRUE;
 	}
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index e1b37f5..c2ea344 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -110,8 +110,8 @@ int __init iriap_init(void)
 	/* Object repository - defined in irias_object.c */
 	irias_objects = hashbin_new(HB_LOCK);
 	if (!irias_objects) {
-		IRDA_WARNING("%s: Can't allocate irias_objects hashbin!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Can't allocate irias_objects hashbin!\n",
+				     __func__);
 		hashbin_delete(iriap, NULL);
 		return -ENOMEM;
 	}
@@ -180,10 +180,8 @@ struct iriap_cb *iriap_open(__u8 slsap_sel, int mode, void *priv,
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	self = kzalloc(sizeof(*self), GFP_ATOMIC);
-	if (!self) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+	if (!self)
 		return NULL;
-	}
 
 	/*
 	 *  Initialize instance
@@ -283,7 +281,8 @@ static int iriap_register_lsap(struct iriap_cb *self, __u8 slsap_sel, int mode)
 
 	self->lsap = irlmp_open_lsap(slsap_sel, &notify, 0);
 	if (self->lsap == NULL) {
-		IRDA_ERROR("%s: Unable to allocated LSAP!\n", __func__);
+		net_err_ratelimited("%s: Unable to allocated LSAP!\n",
+				    __func__);
 		return -1;
 	}
 	self->slsap_sel = self->lsap->slsap_sel;
@@ -859,9 +858,8 @@ static int iriap_data_indication(void *instance, void *sap,
 	}
 	opcode = frame[0];
 	if (~opcode & IAP_LST) {
-		IRDA_WARNING("%s:, IrIAS multiframe commands or "
-			     "results is not implemented yet!\n",
-			     __func__);
+		net_warn_ratelimited("%s:, IrIAS multiframe commands or results is not implemented yet!\n",
+				     __func__);
 		goto out;
 	}
 
@@ -945,16 +943,16 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 
 	opcode = fp[0];
 	if (~opcode & 0x80) {
-		IRDA_WARNING("%s: IrIAS multiframe commands or results "
-			     "is not implemented yet!\n", __func__);
+		net_warn_ratelimited("%s: IrIAS multiframe commands or results is not implemented yet!\n",
+				     __func__);
 		return;
 	}
 	opcode &= 0x7f; /* Mask away LST bit */
 
 	switch (opcode) {
 	case GET_INFO_BASE:
-		IRDA_WARNING("%s: GetInfoBaseDetails not implemented yet!\n",
-			     __func__);
+		net_warn_ratelimited("%s: GetInfoBaseDetails not implemented yet!\n",
+				     __func__);
 		break;
 	case GET_VALUE_BY_CLASS:
 		iriap_getvaluebyclass_indication(self, skb);
diff --git a/net/irda/iriap_event.c b/net/irda/iriap_event.c
index 703774e..09de4ef 100644
--- a/net/irda/iriap_event.c
+++ b/net/irda/iriap_event.c
@@ -368,10 +368,8 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 	switch (event) {
 	case IAP_LM_CONNECT_INDICATION:
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
-		if (tx_skb == NULL) {
-			IRDA_WARNING("%s: unable to malloc!\n", __func__);
+		if (tx_skb == NULL)
 			return;
-		}
 
 		/* Reserve space for MUX_CONTROL and LAP header */
 		skb_reserve(tx_skb, LMP_MAX_HEADER);
diff --git a/net/irda/irias_object.c b/net/irda/irias_object.c
index f07ed9f..cd53692 100644
--- a/net/irda/irias_object.c
+++ b/net/irda/irias_object.c
@@ -52,16 +52,16 @@ struct ias_object *irias_new_object( char *name, int id)
 
 	obj = kzalloc(sizeof(struct ias_object), GFP_ATOMIC);
 	if (obj == NULL) {
-		IRDA_WARNING("%s(), Unable to allocate object!\n",
-			     __func__);
+		net_warn_ratelimited("%s(), Unable to allocate object!\n",
+				     __func__);
 		return NULL;
 	}
 
 	obj->magic = IAS_OBJECT_MAGIC;
 	obj->name = kstrndup(name, IAS_MAX_CLASSNAME, GFP_ATOMIC);
 	if (!obj->name) {
-		IRDA_WARNING("%s(), Unable to allocate name!\n",
-			     __func__);
+		net_warn_ratelimited("%s(), Unable to allocate name!\n",
+				     __func__);
 		kfree(obj);
 		return NULL;
 	}
@@ -73,8 +73,8 @@ struct ias_object *irias_new_object( char *name, int id)
 	obj->attribs = hashbin_new(HB_LOCK);
 
 	if (obj->attribs == NULL) {
-		IRDA_WARNING("%s(), Unable to allocate attribs!\n",
-			     __func__);
+		net_warn_ratelimited("%s(), Unable to allocate attribs!\n",
+				     __func__);
 		kfree(obj->name);
 		kfree(obj);
 		return NULL;
@@ -269,8 +269,8 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 	/* Find object */
 	obj = hashbin_lock_find(irias_objects, 0, obj_name);
 	if (obj == NULL) {
-		IRDA_WARNING("%s: Unable to find object: %s\n", __func__,
-			     obj_name);
+		net_warn_ratelimited("%s: Unable to find object: %s\n",
+				     __func__, obj_name);
 		return -1;
 	}
 
@@ -280,8 +280,8 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 	/* Find attribute */
 	attrib = hashbin_find(obj->attribs, 0, attrib_name);
 	if (attrib == NULL) {
-		IRDA_WARNING("%s: Unable to find attribute: %s\n",
-			     __func__, attrib_name);
+		net_warn_ratelimited("%s: Unable to find attribute: %s\n",
+				     __func__, attrib_name);
 		spin_unlock_irqrestore(&obj->attribs->hb_spinlock, flags);
 		return -1;
 	}
@@ -322,8 +322,8 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 
 	attrib = kzalloc(sizeof(struct ias_attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
-		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
+				     __func__);
 		return;
 	}
 
@@ -333,8 +333,8 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 	/* Insert value */
 	attrib->value = irias_new_integer_value(value);
 	if (!attrib->name || !attrib->value) {
-		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
+				     __func__);
 		if (attrib->value)
 			irias_delete_value(attrib->value);
 		kfree(attrib->name);
@@ -366,8 +366,8 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 
 	attrib = kzalloc(sizeof(struct ias_attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
-		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
+				     __func__);
 		return;
 	}
 
@@ -376,8 +376,8 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 
 	attrib->value = irias_new_octseq_value( octets, len);
 	if (!attrib->name || !attrib->value) {
-		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
+				     __func__);
 		if (attrib->value)
 			irias_delete_value(attrib->value);
 		kfree(attrib->name);
@@ -408,8 +408,8 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 
 	attrib = kzalloc(sizeof( struct ias_attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
-		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
+				     __func__);
 		return;
 	}
 
@@ -418,8 +418,8 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 
 	attrib->value = irias_new_string_value(value);
 	if (!attrib->name || !attrib->value) {
-		IRDA_WARNING("%s: Unable to allocate attribute!\n",
-			     __func__);
+		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
+				     __func__);
 		if (attrib->value)
 			irias_delete_value(attrib->value);
 		kfree(attrib->name);
@@ -442,10 +442,8 @@ struct ias_value *irias_new_integer_value(int integer)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
-	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+	if (value == NULL)
 		return NULL;
-	}
 
 	value->type = IAS_INTEGER;
 	value->len = 4;
@@ -467,16 +465,14 @@ struct ias_value *irias_new_string_value(char *string)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
-	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+	if (value == NULL)
 		return NULL;
-	}
 
 	value->type = IAS_STRING;
 	value->charset = CS_ASCII;
 	value->t.string = kstrndup(string, IAS_MAX_STRING, GFP_ATOMIC);
 	if (!value->t.string) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+		net_warn_ratelimited("%s: Unable to kmalloc!\n", __func__);
 		kfree(value);
 		return NULL;
 	}
@@ -498,10 +494,8 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
-	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+	if (value == NULL)
 		return NULL;
-	}
 
 	value->type = IAS_OCT_SEQ;
 	/* Check length */
@@ -511,7 +505,7 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 
 	value->t.oct_seq = kmemdup(octseq, len, GFP_ATOMIC);
 	if (value->t.oct_seq == NULL){
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+		net_warn_ratelimited("%s: Unable to kmalloc!\n", __func__);
 		kfree(value);
 		return NULL;
 	}
@@ -523,10 +517,8 @@ struct ias_value *irias_new_missing_value(void)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
-	if (value == NULL) {
-		IRDA_WARNING("%s: Unable to kmalloc!\n", __func__);
+	if (value == NULL)
 		return NULL;
-	}
 
 	value->type = IAS_MISSING;
 
diff --git a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
index 42cf139..f8eea02 100644
--- a/net/irda/irlan/irlan_client.c
+++ b/net/irda/irlan/irlan_client.c
@@ -323,34 +323,34 @@ static void print_ret_code(__u8 code)
 		printk(KERN_INFO "Success\n");
 		break;
 	case 1:
-		IRDA_WARNING("IrLAN: Insufficient resources\n");
+		net_warn_ratelimited("IrLAN: Insufficient resources\n");
 		break;
 	case 2:
-		IRDA_WARNING("IrLAN: Invalid command format\n");
+		net_warn_ratelimited("IrLAN: Invalid command format\n");
 		break;
 	case 3:
-		IRDA_WARNING("IrLAN: Command not supported\n");
+		net_warn_ratelimited("IrLAN: Command not supported\n");
 		break;
 	case 4:
-		IRDA_WARNING("IrLAN: Parameter not supported\n");
+		net_warn_ratelimited("IrLAN: Parameter not supported\n");
 		break;
 	case 5:
-		IRDA_WARNING("IrLAN: Value not supported\n");
+		net_warn_ratelimited("IrLAN: Value not supported\n");
 		break;
 	case 6:
-		IRDA_WARNING("IrLAN: Not open\n");
+		net_warn_ratelimited("IrLAN: Not open\n");
 		break;
 	case 7:
-		IRDA_WARNING("IrLAN: Authentication required\n");
+		net_warn_ratelimited("IrLAN: Authentication required\n");
 		break;
 	case 8:
-		IRDA_WARNING("IrLAN: Invalid password\n");
+		net_warn_ratelimited("IrLAN: Invalid password\n");
 		break;
 	case 9:
-		IRDA_WARNING("IrLAN: Protocol error\n");
+		net_warn_ratelimited("IrLAN: Protocol error\n");
 		break;
 	case 255:
-		IRDA_WARNING("IrLAN: Asynchronous status\n");
+		net_warn_ratelimited("IrLAN: Asynchronous status\n");
 		break;
 	}
 }
@@ -380,7 +380,7 @@ void irlan_client_parse_response(struct irlan_cb *self, struct sk_buff *skb)
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
 	if (!skb) {
-		IRDA_ERROR("%s(), Got NULL skb!\n", __func__);
+		net_err_ratelimited("%s(), Got NULL skb!\n", __func__);
 		return;
 	}
 	frame = skb->data;
diff --git a/net/irda/irlan/irlan_client_event.c b/net/irda/irlan/irlan_client_event.c
index 8d5a8eb..f9d11bf 100644
--- a/net/irda/irlan/irlan_client_event.c
+++ b/net/irda/irlan/irlan_client_event.c
@@ -100,8 +100,8 @@ static int irlan_client_state_idle(struct irlan_cb *self, IRLAN_EVENT event,
 	switch (event) {
 	case IRLAN_DISCOVERY_INDICATION:
 		if (self->client.iriap) {
-			IRDA_WARNING("%s(), busy with a previous query\n",
-				     __func__);
+			net_warn_ratelimited("%s(), busy with a previous query\n",
+					     __func__);
 			return -EBUSY;
 		}
 
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 5a2d0a6..cc60b4a 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -437,7 +437,8 @@ static void irlan_disconnect_indication(void *instance,
 		IRDA_DEBUG(2, "%s(), IrLMP connect failed\n", __func__ );
 		break;
 	default:
-		IRDA_ERROR("%s(), Unknown disconnect reason\n", __func__);
+		net_err_ratelimited("%s(), Unknown disconnect reason\n",
+				    __func__);
 		break;
 	}
 
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index dc13f1a..94b948e 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -320,7 +320,7 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
-		IRDA_WARNING("Promiscuous mode not implemented by IrLAN!\n");
+		net_warn_ratelimited("Promiscuous mode not implemented by IrLAN!\n");
 	} else if ((dev->flags & IFF_ALLMULTI) ||
 		 netdev_mc_count(dev) > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index a778df5..2e3bc6c 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -85,8 +85,8 @@ int __init irlap_init(void)
 	/* Allocate master array */
 	irlap = hashbin_new(HB_LOCK);
 	if (irlap == NULL) {
-		IRDA_ERROR("%s: can't allocate irlap hashbin!\n",
-			   __func__);
+		net_err_ratelimited("%s: can't allocate irlap hashbin!\n",
+				    __func__);
 		return -ENOMEM;
 	}
 
@@ -491,7 +491,8 @@ void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 						 reason, NULL);
 		break;
 	default:
-		IRDA_ERROR("%s: Unknown reason %d\n", __func__, reason);
+		net_err_ratelimited("%s: Unknown reason %d\n",
+				    __func__, reason);
 	}
 }
 
@@ -540,8 +541,8 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 	self->discovery_log = hashbin_new(HB_NOLOCK);
 
 	if (self->discovery_log == NULL) {
-		IRDA_WARNING("%s(), Unable to allocate discovery log!\n",
-			     __func__);
+		net_warn_ratelimited("%s(), Unable to allocate discovery log!\n",
+				     __func__);
 		return;
 	}
 
@@ -625,10 +626,10 @@ void irlap_status_indication(struct irlap_cb *self, int quality_of_link)
 {
 	switch (quality_of_link) {
 	case STATUS_NO_ACTIVITY:
-		IRDA_MESSAGE("IrLAP, no activity on link!\n");
+		net_info_ratelimited("IrLAP, no activity on link!\n");
 		break;
 	case STATUS_NOISY:
-		IRDA_MESSAGE("IrLAP, noisy link!\n");
+		net_info_ratelimited("IrLAP, noisy link!\n");
 		break;
 	default:
 		break;
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index ccd214f..5f4a84e 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -572,9 +572,8 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 			   info->discovery->data.daddr);
 
 		if (!self->discovery_log) {
-			IRDA_WARNING("%s: discovery log is gone! "
-				     "maybe the discovery timeout has been set"
-				     " too short?\n", __func__);
+			net_warn_ratelimited("%s: discovery log is gone! maybe the discovery timeout has been set too short?\n",
+					     __func__);
 			break;
 		}
 		hashbin_insert(self->discovery_log,
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index a37998c..90ef036 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -421,7 +421,7 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
-		IRDA_ERROR("%s: frame too short!\n", __func__);
+		net_err_ratelimited("%s: frame too short!\n", __func__);
 		return;
 	}
 
@@ -438,7 +438,7 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	}
 
 	if ((discovery = kzalloc(sizeof(discovery_t), GFP_ATOMIC)) == NULL) {
-		IRDA_WARNING("%s: kmalloc failed!\n", __func__);
+		net_warn_ratelimited("%s: kmalloc failed!\n", __func__);
 		return;
 	}
 
@@ -492,7 +492,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 	char *text;
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
-		IRDA_ERROR("%s: frame too short!\n", __func__);
+		net_err_ratelimited("%s: frame too short!\n", __func__);
 		return;
 	}
 
@@ -536,8 +536,8 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 		/* Check if things are sane at this point... */
 		if((discovery_info == NULL) ||
 		   !pskb_may_pull(skb, 3)) {
-			IRDA_ERROR("%s: discovery frame too short!\n",
-				   __func__);
+			net_err_ratelimited("%s: discovery frame too short!\n",
+					    __func__);
 			return;
 		}
 
@@ -545,10 +545,8 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 		 *  We now have some discovery info to deliver!
 		 */
 		discovery = kzalloc(sizeof(discovery_t), GFP_ATOMIC);
-		if (!discovery) {
-			IRDA_WARNING("%s: unable to malloc!\n", __func__);
+		if (!discovery)
 			return;
-		}
 
 		discovery->data.daddr = info->daddr;
 		discovery->data.saddr = self->saddr;
@@ -1170,7 +1168,7 @@ static void irlap_recv_frmr_frame(struct irlap_cb *self, struct sk_buff *skb,
 	IRDA_ASSERT(info != NULL, return;);
 
 	if (!pskb_may_pull(skb, 4)) {
-		IRDA_ERROR("%s: frame too short!\n", __func__);
+		net_err_ratelimited("%s: frame too short!\n", __func__);
 		return;
 	}
 
@@ -1259,7 +1257,7 @@ static void irlap_recv_test_frame(struct irlap_cb *self, struct sk_buff *skb,
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (!pskb_may_pull(skb, sizeof(*frame))) {
-		IRDA_ERROR("%s: frame too short!\n", __func__);
+		net_err_ratelimited("%s: frame too short!\n", __func__);
 		return;
 	}
 	frame = (struct test_frame *) skb->data;
@@ -1328,13 +1326,13 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * share and non linear skbs. This should never happen, so
 	 * we don't need to be clever about it. Jean II */
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		IRDA_ERROR("%s: can't clone shared skb!\n", __func__);
+		net_err_ratelimited("%s: can't clone shared skb!\n", __func__);
 		goto err;
 	}
 
 	/* Check if frame is large enough for parsing */
 	if (!pskb_may_pull(skb, 2)) {
-		IRDA_ERROR("%s: frame too short!\n", __func__);
+		net_err_ratelimited("%s: frame too short!\n", __func__);
 		goto err;
 	}
 
@@ -1383,8 +1381,8 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 			irlap_recv_srej_frame(self, skb, &info, command);
 			break;
 		default:
-			IRDA_WARNING("%s: Unknown S-frame %02x received!\n",
-				__func__, info.control);
+			net_warn_ratelimited("%s: Unknown S-frame %02x received!\n",
+					     __func__, info.control);
 			break;
 		}
 		goto out;
@@ -1421,8 +1419,8 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 		irlap_recv_ui_frame(self, skb, &info);
 		break;
 	default:
-		IRDA_WARNING("%s: Unknown frame %02x received!\n",
-				__func__, info.control);
+		net_warn_ratelimited("%s: Unknown frame %02x received!\n",
+				     __func__, info.control);
 		break;
 	}
 out:
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index a5f28d4..6178e71 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -170,10 +170,8 @@ struct lsap_cb *irlmp_open_lsap(__u8 slsap_sel, notify_t *notify, __u8 pid)
 
 	/* Allocate new instance of a LSAP connection */
 	self = kzalloc(sizeof(struct lsap_cb), GFP_ATOMIC);
-	if (self == NULL) {
-		IRDA_ERROR("%s: can't allocate memory\n", __func__);
+	if (self == NULL)
 		return NULL;
-	}
 
 	self->magic = LMP_LSAP_MAGIC;
 	self->slsap_sel = slsap_sel;
@@ -297,10 +295,8 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 	 *  Allocate new instance of a LSAP connection
 	 */
 	lap = kzalloc(sizeof(struct lap_cb), GFP_KERNEL);
-	if (lap == NULL) {
-		IRDA_ERROR("%s: unable to kmalloc\n", __func__);
+	if (lap == NULL)
 		return;
-	}
 
 	lap->irlap = irlap;
 	lap->magic = LMP_LAP_MAGIC;
@@ -311,7 +307,8 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 #endif
 	lap->lsaps = hashbin_new(HB_LOCK);
 	if (lap->lsaps == NULL) {
-		IRDA_WARNING("%s(), unable to kmalloc lsaps\n", __func__);
+		net_warn_ratelimited("%s(), unable to kmalloc lsaps\n",
+				     __func__);
 		kfree(lap);
 		return;
 	}
@@ -852,8 +849,8 @@ void irlmp_do_discovery(int nslots)
 
 	/* Make sure the value is sane */
 	if ((nslots != 1) && (nslots != 6) && (nslots != 8) && (nslots != 16)){
-		IRDA_WARNING("%s: invalid value for number of slots!\n",
-			     __func__);
+		net_warn_ratelimited("%s: invalid value for number of slots!\n",
+				     __func__);
 		nslots = sysctl_discovery_slots = 8;
 	}
 
@@ -1799,8 +1796,8 @@ static __u8 irlmp_find_free_slsap(void)
 
 			/* Make sure we terminate the loop */
 			if (wrapped++) {
-				IRDA_ERROR("%s: no more free LSAPs !\n",
-					   __func__);
+				net_err_ratelimited("%s: no more free LSAPs !\n",
+						    __func__);
 				return 0;
 			}
 		}
diff --git a/net/irda/irlmp_event.c b/net/irda/irlmp_event.c
index 9505a7d..30e51f9 100644
--- a/net/irda/irlmp_event.c
+++ b/net/irda/irlmp_event.c
@@ -508,8 +508,8 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 		IRDA_DEBUG(4, "%s(), LM_CONNECT_REQUEST\n", __func__);
 
 		if (self->conn_skb) {
-			IRDA_WARNING("%s: busy with another request!\n",
-				     __func__);
+			net_warn_ratelimited("%s: busy with another request!\n",
+					     __func__);
 			return -EBUSY;
 		}
 		/* Don't forget to refcount it (see irlmp_connect_request()) */
@@ -525,8 +525,8 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 		break;
 	case LM_CONNECT_INDICATION:
 		if (self->conn_skb) {
-			IRDA_WARNING("%s: busy with another request!\n",
-				     __func__);
+			net_warn_ratelimited("%s: busy with another request!\n",
+					     __func__);
 			return -EBUSY;
 		}
 		/* Don't forget to refcount it (see irlap_driver_rcv()) */
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 85372cf..e0b2b0d 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -96,8 +96,8 @@ int __init irttp_init(void)
 
 	irttp->tsaps = hashbin_new(HB_LOCK);
 	if (!irttp->tsaps) {
-		IRDA_ERROR("%s: can't allocate IrTTP hashbin!\n",
-			   __func__);
+		net_err_ratelimited("%s: can't allocate IrTTP hashbin!\n",
+				    __func__);
 		kfree(irttp);
 		return -ENOMEM;
 	}
@@ -518,8 +518,8 @@ int irttp_close_tsap(struct tsap_cb *self)
 	if (self->connected) {
 		/* Check if disconnect is not pending */
 		if (!test_bit(0, &self->disconnect_pend)) {
-			IRDA_WARNING("%s: TSAP still connected!\n",
-				     __func__);
+			net_warn_ratelimited("%s: TSAP still connected!\n",
+					     __func__);
 			irttp_disconnect_request(self, NULL, P_NORMAL);
 		}
 		self->close_pend = TRUE;
@@ -568,13 +568,14 @@ int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 
 	/* Check that nothing bad happens */
 	if (!self->connected) {
-		IRDA_WARNING("%s(), Not connected\n", __func__);
+		net_warn_ratelimited("%s(), Not connected\n", __func__);
 		ret = -ENOTCONN;
 		goto err;
 	}
 
 	if (skb->len > self->max_seg_size) {
-		IRDA_ERROR("%s(), UData is too large for IrLAP!\n", __func__);
+		net_err_ratelimited("%s(), UData is too large for IrLAP!\n",
+				    __func__);
 		ret = -EMSGSIZE;
 		goto err;
 	}
@@ -617,7 +618,7 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 
 	/* Check that nothing bad happens */
 	if (!self->connected) {
-		IRDA_WARNING("%s: Not connected\n", __func__);
+		net_warn_ratelimited("%s: Not connected\n", __func__);
 		ret = -ENOTCONN;
 		goto err;
 	}
@@ -627,8 +628,8 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	 *  inside an IrLAP frame
 	 */
 	if ((self->tx_max_sdu_size == 0) && (skb->len > self->max_seg_size)) {
-		IRDA_ERROR("%s: SAR disabled, and data is too large for IrLAP!\n",
-			   __func__);
+		net_err_ratelimited("%s: SAR disabled, and data is too large for IrLAP!\n",
+				    __func__);
 		ret = -EMSGSIZE;
 		goto err;
 	}
@@ -640,8 +641,8 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	if ((self->tx_max_sdu_size != 0) &&
 	    (self->tx_max_sdu_size != TTP_SAR_UNBOUND) &&
 	    (skb->len > self->tx_max_sdu_size)) {
-		IRDA_ERROR("%s: SAR enabled, but data is larger than TxMaxSduSize!\n",
-			   __func__);
+		net_err_ratelimited("%s: SAR enabled, but data is larger than TxMaxSduSize!\n",
+				    __func__);
 		ret = -EMSGSIZE;
 		goto err;
 	}
@@ -1249,8 +1250,8 @@ static void irttp_connect_confirm(void *instance, void *sap,
 
 		/* Any errors in the parameter list? */
 		if (ret < 0) {
-			IRDA_WARNING("%s: error extracting parameters\n",
-				     __func__);
+			net_warn_ratelimited("%s: error extracting parameters\n",
+					     __func__);
 			dev_kfree_skb(skb);
 
 			/* Do not accept this connection attempt */
@@ -1326,8 +1327,8 @@ static void irttp_connect_indication(void *instance, void *sap,
 
 		/* Any errors in the parameter list? */
 		if (ret < 0) {
-			IRDA_WARNING("%s: error extracting parameters\n",
-				     __func__);
+			net_warn_ratelimited("%s: error extracting parameters\n",
+					     __func__);
 			dev_kfree_skb(skb);
 
 			/* Do not accept this connection attempt */
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index 6d08697..d7a5778 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -158,8 +158,8 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 	}
 	/* Check if buffer is long enough for insertion */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer too short for insertion!\n",
-			     __func__);
+		net_warn_ratelimited("%s: buffer too short for insertion!\n",
+				     __func__);
 		return -1;
 	}
 	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d, pi=%d\n", __func__,
@@ -184,8 +184,8 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 
 		break;
 	default:
-		IRDA_WARNING("%s: length %d not supported\n",
-			     __func__, p.pl);
+		net_warn_ratelimited("%s: length %d not supported\n",
+				     __func__, p.pl);
 		/* Skip parameter */
 		return -1;
 	}
@@ -214,9 +214,8 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer too short for parsing! "
-			     "Need %d bytes, but len is only %d\n",
-			     __func__, p.pl, len);
+		net_warn_ratelimited("%s: buffer too short for parsing! Need %d bytes, but len is only %d\n",
+				     __func__, p.pl, len);
 		return -1;
 	}
 
@@ -226,9 +225,8 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 	 * PV_INTEGER means that the handler is flexible.
 	 */
 	if (((type & PV_MASK) != PV_INTEGER) && ((type & PV_MASK) != p.pl)) {
-		IRDA_ERROR("%s: invalid parameter length! "
-			   "Expected %d bytes, but value had %d bytes!\n",
-			   __func__, type & PV_MASK, p.pl);
+		net_err_ratelimited("%s: invalid parameter length! Expected %d bytes, but value had %d bytes!\n",
+				    __func__, type & PV_MASK, p.pl);
 
 		/* Most parameters are bit/byte fields or little endian,
 		 * so it's ok to only extract a subset of it (the subset
@@ -265,8 +263,8 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 			le32_to_cpus(&p.pv.i);
 		break;
 	default:
-		IRDA_WARNING("%s: length %d not supported\n",
-			     __func__, p.pl);
+		net_warn_ratelimited("%s: length %d not supported\n",
+				     __func__, p.pl);
 
 		/* Skip parameter */
 		return p.pl+2;
@@ -304,9 +302,8 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer too short for parsing! "
-			     "Need %d bytes, but len is only %d\n",
-			     __func__, p.pl, len);
+		net_warn_ratelimited("%s: buffer too short for parsing! Need %d bytes, but len is only %d\n",
+				     __func__, p.pl, len);
 		return -1;
 	}
 
@@ -343,9 +340,8 @@ static int irda_extract_octseq(void *self, __u8 *buf, int len, __u8 pi,
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer too short for parsing! "
-			     "Need %d bytes, but len is only %d\n",
-			     __func__, p.pl, len);
+		net_warn_ratelimited("%s: buffer too short for parsing! Need %d bytes, but len is only %d\n",
+				     __func__, p.pl, len);
 		return -1;
 	}
 
@@ -487,7 +483,8 @@ int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
 
 	/*  Check if handler has been implemented */
 	if (!pi_minor_info->func) {
-		IRDA_MESSAGE("%s: no handler for pi=%#x\n", __func__, pi);
+		net_info_ratelimited("%s: no handler for pi=%#x\n",
+				     __func__, pi);
 		/* Skip this parameter */
 		return -1;
 	}
@@ -544,8 +541,8 @@ static int irda_param_extract(void *self, __u8 *buf, int len,
 
 	/*  Check if handler has been implemented */
 	if (!pi_minor_info->func) {
-		IRDA_MESSAGE("%s: no handler for pi=%#x\n",
-			     __func__, buf[n]);
+		net_info_ratelimited("%s: no handler for pi=%#x\n",
+				     __func__, buf[n]);
 		/* Skip this parameter */
 		return 2 + buf[n + 1]; /* Continue */
 	}
diff --git a/net/irda/qos.c b/net/irda/qos.c
index 11a7cc0..f3b588c 100644
--- a/net/irda/qos.c
+++ b/net/irda/qos.c
@@ -200,8 +200,8 @@ static int msb_index (__u16 word)
 	 * able to check precisely what's going on. If a end user sees this,
 	 * it's very likely the peer. - Jean II */
 	if (word == 0) {
-		IRDA_WARNING("%s(), Detected buggy peer, adjust null PV to 0x1!\n",
-			 __func__);
+		net_warn_ratelimited("%s(), Detected buggy peer, adjust null PV to 0x1!\n",
+				     __func__);
 		/* The only safe choice (we don't know the array size) */
 		word = 0x1;
 	}
@@ -351,8 +351,8 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 	if (sysctl_min_tx_turn_time > qos->min_turn_time.value) {
 		int i;
 
-		IRDA_WARNING("%s(), Detected buggy peer, adjust mtt to %dus!\n",
-			 __func__, sysctl_min_tx_turn_time);
+		net_warn_ratelimited("%s(), Detected buggy peer, adjust mtt to %dus!\n",
+				     __func__, sysctl_min_tx_turn_time);
 
 		/* We don't really need bits, but easier this way */
 		i = value_highest_bit(sysctl_min_tx_turn_time, min_turn_times,
@@ -402,8 +402,8 @@ static void irlap_adjust_qos_settings(struct qos_info *qos)
 			IRDA_DEBUG(2, "%s(), reducing data size to %d\n",
 				   __func__, qos->data_size.value);
 		} else {
-			IRDA_WARNING("%s(), nothing more we can do!\n",
-				     __func__);
+			net_warn_ratelimited("%s(), nothing more we can do!\n",
+					     __func__);
 		}
 	}
 #endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index fd0995b..9efffeb 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -134,8 +134,8 @@ int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 		 *  transmitted after this point is 5.
 		 */
 		if(n >= (buffsize-5)) {
-			IRDA_ERROR("%s(), tx buffer overflow (n=%d)\n",
-				   __func__, n);
+			net_err_ratelimited("%s(), tx buffer overflow (n=%d)\n",
+					    __func__, n);
 			return n;
 		}
 
@@ -386,7 +386,7 @@ async_unwrap_ce(struct net_device *dev,
 		break;
 
 	case LINK_ESCAPE:
-		IRDA_WARNING("%s: state not defined\n", __func__);
+		net_warn_ratelimited("%s: state not defined\n", __func__);
 		break;
 
 	case BEGIN_FRAME:
