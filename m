From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] usbnet: Style cleanups
Date: Tue,  3 May 2011 11:17:57 -0700
Message-ID: <3592918df9ee156047042aae16531e96db0b7144.1304445019.git.joe@perches.com>
References: <cover.1304445019.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304445019.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just general neatening.

Remove spaces before function open parentheses.
Add spaces around sizeof uses.
Convert c99 comments to /* */
Hoist assigns from if where appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/usbnet.c |  625 +++++++++++++++++++++++----------------------
 1 files changed, 319 insertions(+), 306 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 7bc9852..28aecbb 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -30,8 +30,8 @@
  * issues can usefully be addressed by this framework.
  */
 
-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
+/* #define	DEBUG			// error path messages, extra info */
+/* #define	VERBOSE			// more; success messages */
 
 #include <linux/module.h>
 #include <linux/init.h>
@@ -64,32 +64,31 @@
  * is required, under load.  Jumbograms change the equation.
  */
 #define RX_MAX_QUEUE_MEMORY (60 * 1518)
-#define	RX_QLEN(dev) (((dev)->udev->speed == USB_SPEED_HIGH) ? \
-			(RX_MAX_QUEUE_MEMORY/(dev)->rx_urb_size) : 4)
-#define	TX_QLEN(dev) (((dev)->udev->speed == USB_SPEED_HIGH) ? \
-			(RX_MAX_QUEUE_MEMORY/(dev)->hard_mtu) : 4)
+#define	RX_QLEN(dev) (((dev)->udev->speed == USB_SPEED_HIGH) ?		\
+		      (RX_MAX_QUEUE_MEMORY/(dev)->rx_urb_size) : 4)
+#define	TX_QLEN(dev) (((dev)->udev->speed == USB_SPEED_HIGH) ?		\
+		      (RX_MAX_QUEUE_MEMORY/(dev)->hard_mtu) : 4)
 
-// reawaken network queue this soon after stopping; else watchdog barks
+/* reawaken network queue this soon after stopping; else watchdog barks */
 #define TX_TIMEOUT_JIFFIES	(5*HZ)
 
-// throttle rx/tx briefly after some faults, so khubd might disconnect()
-// us (it polls at HZ/4 usually) before we report too many false errors.
+/* throttle rx/tx briefly after some faults, so khubd might disconnect()
+ * us (it polls at HZ/4 usually) before we report too many false errors.
+ */
 #define THROTTLE_JIFFIES	(HZ/8)
 
-// between wakeups
-#define UNLINK_TIMEOUT_MS	3
+#define UNLINK_TIMEOUT_MS	3	/* between wakeups */
 
 /*-------------------------------------------------------------------------*/
 
-// randomly generated ethernet address
-static u8	node_id [ETH_ALEN];
+static u8 node_id[ETH_ALEN];	/* randomly generated ethernet address */
 
-static const char driver_name [] = "usbnet";
+static const char driver_name[] = "usbnet";
 
 /* use ethtool to change the level for any given device */
 static int msg_level = -1;
-module_param (msg_level, int, 0);
-MODULE_PARM_DESC (msg_level, "Override default message level");
+module_param(msg_level, int, 0);
+MODULE_PARM_DESC(msg_level, "Override default message level");
 
 /*-------------------------------------------------------------------------*/
 
@@ -145,15 +144,15 @@ int usbnet_get_endpoints(struct usbnet *dev, struct usb_interface *intf)
 
 	if (alt->desc.bAlternateSetting != 0 ||
 	    !(dev->driver_info->flags & FLAG_NO_SETINT)) {
-		tmp = usb_set_interface (dev->udev, alt->desc.bInterfaceNumber,
-				alt->desc.bAlternateSetting);
+		tmp = usb_set_interface(dev->udev, alt->desc.bInterfaceNumber,
+					alt->desc.bAlternateSetting);
 		if (tmp < 0)
 			return tmp;
 	}
 
-	dev->in = usb_rcvbulkpipe (dev->udev,
+	dev->in = usb_rcvbulkpipe(dev->udev,
 			in->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
-	dev->out = usb_sndbulkpipe (dev->udev,
+	dev->out = usb_sndbulkpipe(dev->udev,
 			out->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
 	dev->status = status;
 	return 0;
@@ -162,27 +161,27 @@ EXPORT_SYMBOL_GPL(usbnet_get_endpoints);
 
 int usbnet_get_ethernet_addr(struct usbnet *dev, int iMACAddress)
 {
-	int 		tmp, i;
-	unsigned char	buf [13];
+	int		tmp, i;
+	unsigned char	buf[13];
 
-	tmp = usb_string(dev->udev, iMACAddress, buf, sizeof buf);
+	tmp = usb_string(dev->udev, iMACAddress, buf, sizeof(buf));
 	if (tmp != 12) {
-		dev_dbg(&dev->udev->dev,
-			"bad MAC string %d fetch, %d\n", iMACAddress, tmp);
+		dev_dbg(&dev->udev->dev, "bad MAC string %d fetch, %d\n",
+			iMACAddress, tmp);
 		if (tmp >= 0)
 			tmp = -EINVAL;
 		return tmp;
 	}
 	for (i = tmp = 0; i < 6; i++, tmp += 2)
-		dev->net->dev_addr [i] =
+		dev->net->dev_addr[i] =
 			(hex_to_bin(buf[tmp]) << 4) + hex_to_bin(buf[tmp + 1]);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_get_ethernet_addr);
 
-static void intr_complete (struct urb *urb);
+static void intr_complete(struct urb *urb);
 
-static int init_status (struct usbnet *dev, struct usb_interface *intf)
+static int init_status(struct usbnet *dev, struct usb_interface *intf)
 {
 	char		*buf = NULL;
 	unsigned	pipe = 0;
@@ -192,24 +191,24 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 	if (!dev->driver_info->status)
 		return 0;
 
-	pipe = usb_rcvintpipe (dev->udev,
-			dev->status->desc.bEndpointAddress
-				& USB_ENDPOINT_NUMBER_MASK);
-	maxp = usb_maxpacket (dev->udev, pipe, 0);
+	pipe = usb_rcvintpipe(dev->udev,
+			      dev->status->desc.bEndpointAddress
+			      & USB_ENDPOINT_NUMBER_MASK);
+	maxp = usb_maxpacket(dev->udev, pipe, 0);
 
 	/* avoid 1 msec chatter:  min 8 msec poll rate */
-	period = max ((int) dev->status->desc.bInterval,
-		(dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
+	period = max((int)dev->status->desc.bInterval,
+		     (dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
 
-	buf = kmalloc (maxp, GFP_KERNEL);
+	buf = kmalloc(maxp, GFP_KERNEL);
 	if (buf) {
-		dev->interrupt = usb_alloc_urb (0, GFP_KERNEL);
+		dev->interrupt = usb_alloc_urb(0, GFP_KERNEL);
 		if (!dev->interrupt) {
-			kfree (buf);
+			kfree(buf);
 			return -ENOMEM;
 		} else {
 			usb_fill_int_urb(dev->interrupt, dev->udev, pipe,
-				buf, maxp, intr_complete, dev, period);
+					 buf, maxp, intr_complete, dev, period);
 			dev_dbg(&intf->dev,
 				"status ep%din, %d bytes period %d\n",
 				usb_pipeendpoint(pipe), maxp, period);
@@ -222,7 +221,7 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
  * Some link protocols batch packets, so their rx_fixup paths
  * can return clones as well as just modify the original skb.
  */
-void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
+void usbnet_skb_return(struct usbnet *dev, struct sk_buff *skb)
 {
 	int	status;
 
@@ -231,28 +230,27 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 		return;
 	}
 
-	skb->protocol = eth_type_trans (skb, dev->net);
+	skb->protocol = eth_type_trans(skb, dev->net);
 	dev->net->stats.rx_packets++;
 	dev->net->stats.rx_bytes += skb->len;
 
 	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
-		  skb->len + sizeof (struct ethhdr), skb->protocol);
-	memset (skb->cb, 0, sizeof (struct skb_data));
-	status = netif_rx (skb);
+		  skb->len + sizeof(struct ethhdr), skb->protocol);
+	memset(skb->cb, 0, sizeof(struct skb_data));
+	status = netif_rx(skb);
 	if (status != NET_RX_SUCCESS)
 		netif_dbg(dev, rx_err, dev->net,
 			  "netif_rx status %d\n", status);
 }
 EXPORT_SYMBOL_GPL(usbnet_skb_return);
 
-
 /*-------------------------------------------------------------------------
  *
  * Network Device Driver (peer link to "Host Device", from USB host)
  *
  *-------------------------------------------------------------------------*/
 
-int usbnet_change_mtu (struct net_device *net, int new_mtu)
+int usbnet_change_mtu(struct net_device *net, int new_mtu)
 {
 	struct usbnet	*dev = netdev_priv(net);
 	int		ll_mtu = new_mtu + net->hard_header_len;
@@ -261,7 +259,7 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 
 	if (new_mtu <= 0)
 		return -EINVAL;
-	// no second zero-length packet read wanted after mtu-sized packets
+	/* no second zero-length packet read wanted after mtu-sized packets */
 	if ((ll_mtu % dev->maxpacket) == 0)
 		return -EDOM;
 	net->mtu = new_mtu;
@@ -283,7 +281,8 @@ EXPORT_SYMBOL_GPL(usbnet_change_mtu);
  * completion callbacks.  2.5 should have fixed those bugs...
  */
 
-static void defer_bh(struct usbnet *dev, struct sk_buff *skb, struct sk_buff_head *list)
+static void
+defer_bh(struct usbnet *dev, struct sk_buff *skb, struct sk_buff_head *list)
 {
 	unsigned long		flags;
 
@@ -302,10 +301,10 @@ static void defer_bh(struct usbnet *dev, struct sk_buff *skb, struct sk_buff_hea
  * NOTE:  annoying asymmetry:  if it's active, schedule_work() fails,
  * but tasklet_schedule() doesn't.  hope the failure is rare.
  */
-void usbnet_defer_kevent (struct usbnet *dev, int work)
+void usbnet_defer_kevent(struct usbnet *dev, int work)
 {
-	set_bit (work, &dev->flags);
-	if (!schedule_work (&dev->kevent))
+	set_bit(work, &dev->flags);
+	if (!schedule_work(&dev->kevent))
 		netdev_err(dev->net, "kevent %d may have been dropped\n", work);
 	else
 		netdev_dbg(dev->net, "kevent %d scheduled\n", work);
@@ -314,9 +313,9 @@ EXPORT_SYMBOL_GPL(usbnet_defer_kevent);
 
 /*-------------------------------------------------------------------------*/
 
-static void rx_complete (struct urb *urb);
+static void rx_complete(struct urb *urb);
 
-static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
+static int rx_submit(struct usbnet *dev, struct urb *urb, gfp_t flags)
 {
 	struct sk_buff		*skb;
 	struct skb_data		*entry;
@@ -324,39 +323,40 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	unsigned long		lockflags;
 	size_t			size = dev->rx_urb_size;
 
-	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
+	skb = alloc_skb(size + NET_IP_ALIGN, flags);
+	if (!skb) {
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
-		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
-		usb_free_urb (urb);
+		usbnet_defer_kevent(dev, EVENT_RX_MEMORY);
+		usb_free_urb(urb);
 		return -ENOMEM;
 	}
-	skb_reserve (skb, NET_IP_ALIGN);
+	skb_reserve(skb, NET_IP_ALIGN);
 
-	entry = (struct skb_data *) skb->cb;
+	entry = (struct skb_data *)skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
 	entry->state = rx_start;
 	entry->length = 0;
 
-	usb_fill_bulk_urb (urb, dev->udev, dev->in,
-		skb->data, size, rx_complete, skb);
+	usb_fill_bulk_urb(urb, dev->udev, dev->in,
+			  skb->data, size, rx_complete, skb);
 
-	spin_lock_irqsave (&dev->rxq.lock, lockflags);
+	spin_lock_irqsave(&dev->rxq.lock, lockflags);
 
-	if (netif_running (dev->net) &&
-	    netif_device_present (dev->net) &&
-	    !test_bit (EVENT_RX_HALT, &dev->flags) &&
-	    !test_bit (EVENT_DEV_ASLEEP, &dev->flags)) {
-		switch (retval = usb_submit_urb (urb, GFP_ATOMIC)) {
+	if (netif_running(dev->net) &&
+	    netif_device_present(dev->net) &&
+	    !test_bit(EVENT_RX_HALT, &dev->flags) &&
+	    !test_bit(EVENT_DEV_ASLEEP, &dev->flags)) {
+		switch (retval = usb_submit_urb(urb, GFP_ATOMIC)) {
 		case -EPIPE:
-			usbnet_defer_kevent (dev, EVENT_RX_HALT);
+			usbnet_defer_kevent(dev, EVENT_RX_HALT);
 			break;
 		case -ENOMEM:
-			usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
+			usbnet_defer_kevent(dev, EVENT_RX_MEMORY);
 			break;
 		case -ENODEV:
 			netif_dbg(dev, ifdown, dev->net, "device gone\n");
-			netif_device_detach (dev->net);
+			netif_device_detach(dev->net);
 			break;
 		case -EHOSTUNREACH:
 			retval = -ENOLINK;
@@ -364,19 +364,19 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 		default:
 			netif_dbg(dev, rx_err, dev->net,
 				  "rx submit, %d\n", retval);
-			tasklet_schedule (&dev->bh);
+			tasklet_schedule(&dev->bh);
 			break;
 		case 0:
-			__skb_queue_tail (&dev->rxq, skb);
+			__skb_queue_tail(&dev->rxq, skb);
 		}
 	} else {
 		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
 		retval = -ENOLINK;
 	}
-	spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
+	spin_unlock_irqrestore(&dev->rxq.lock, lockflags);
 	if (retval) {
-		dev_kfree_skb_any (skb);
-		usb_free_urb (urb);
+		dev_kfree_skb_any(skb);
+		usb_free_urb(urb);
 	}
 	return retval;
 }
@@ -384,16 +384,16 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 
 /*-------------------------------------------------------------------------*/
 
-static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
+static inline void rx_process(struct usbnet *dev, struct sk_buff *skb)
 {
 	if (dev->driver_info->rx_fixup &&
-	    !dev->driver_info->rx_fixup (dev, skb)) {
+	    !dev->driver_info->rx_fixup(dev, skb)) {
 		/* With RX_ASSEMBLE, rx_fixup() must update counters */
 		if (!(dev->driver_info->flags & FLAG_RX_ASSEMBLE))
 			dev->net->stats.rx_errors++;
 		goto done;
 	}
-	// else network stack removes extra byte if we forced a short packet
+	/* else network stack removes extra byte if we forced a short packet */
 
 	if (skb->len) {
 		/* all data was already cloned from skb inside the driver */
@@ -412,19 +412,19 @@ done:
 
 /*-------------------------------------------------------------------------*/
 
-static void rx_complete (struct urb *urb)
+static void rx_complete(struct urb *urb)
 {
-	struct sk_buff		*skb = (struct sk_buff *) urb->context;
-	struct skb_data		*entry = (struct skb_data *) skb->cb;
+	struct sk_buff		*skb = (struct sk_buff *)urb->context;
+	struct skb_data		*entry = (struct skb_data *)skb->cb;
 	struct usbnet		*dev = entry->dev;
 	int			urb_status = urb->status;
 
-	skb_put (skb, urb->actual_length);
+	skb_put(skb, urb->actual_length);
 	entry->state = rx_done;
 	entry->urb = NULL;
 
 	switch (urb_status) {
-	/* success */
+		/* success */
 	case 0:
 		if (skb->len < dev->net->hard_header_len) {
 			entry->state = rx_cleanup;
@@ -435,33 +435,34 @@ static void rx_complete (struct urb *urb)
 		}
 		break;
 
-	/* stalls need manual reset. this is rare ... except that
-	 * when going through USB 2.0 TTs, unplug appears this way.
-	 * we avoid the highspeed version of the ETIMEDOUT/EILSEQ
-	 * storm, recovering as needed.
-	 */
+		/* stalls need manual reset. this is rare ... except that
+		 * when going through USB 2.0 TTs, unplug appears this way.
+		 * we avoid the highspeed version of the ETIMEDOUT/EILSEQ
+		 * storm, recovering as needed.
+		 */
 	case -EPIPE:
 		dev->net->stats.rx_errors++;
-		usbnet_defer_kevent (dev, EVENT_RX_HALT);
-		// FALLTHROUGH
+		usbnet_defer_kevent(dev, EVENT_RX_HALT);
+		/* FALLTHROUGH */
 
-	/* software-driven interface shutdown */
+		/* software-driven interface shutdown */
 	case -ECONNRESET:		/* async unlink */
 	case -ESHUTDOWN:		/* hardware gone */
 		netif_dbg(dev, ifdown, dev->net,
 			  "rx shutdown, code %d\n", urb_status);
 		goto block;
 
-	/* we get controller i/o faults during khubd disconnect() delays.
-	 * throttle down resubmits, to avoid log floods; just temporarily,
-	 * so we still recover when the fault isn't a khubd delay.
-	 */
+		/* we get controller i/o faults during khubd disconnect()
+		 * delays.  Throttle down resubmits, to avoid log floods;
+		 * just temporarily, so we still recover when the fault
+		 * isn't a khubd delay.
+		 */
 	case -EPROTO:
 	case -ETIME:
 	case -EILSEQ:
 		dev->net->stats.rx_errors++;
-		if (!timer_pending (&dev->delay)) {
-			mod_timer (&dev->delay, jiffies + THROTTLE_JIFFIES);
+		if (!timer_pending(&dev->delay)) {
+			mod_timer(&dev->delay, jiffies + THROTTLE_JIFFIES);
 			netif_dbg(dev, link, dev->net,
 				  "rx throttle %d\n", urb_status);
 		}
@@ -471,10 +472,10 @@ block:
 		urb = NULL;
 		break;
 
-	/* data overrun ... flush fifo? */
+		/* data overrun ... flush fifo? */
 	case -EOVERFLOW:
 		dev->net->stats.rx_over_errors++;
-		// FALLTHROUGH
+		/* FALLTHROUGH */
 
 	default:
 		entry->state = rx_cleanup;
@@ -486,47 +487,47 @@ block:
 	defer_bh(dev, skb, &dev->rxq);
 
 	if (urb) {
-		if (netif_running (dev->net) &&
-		    !test_bit (EVENT_RX_HALT, &dev->flags)) {
-			rx_submit (dev, urb, GFP_ATOMIC);
+		if (netif_running(dev->net) &&
+		    !test_bit(EVENT_RX_HALT, &dev->flags)) {
+			rx_submit(dev, urb, GFP_ATOMIC);
 			return;
 		}
-		usb_free_urb (urb);
+		usb_free_urb(urb);
 	}
 	netif_dbg(dev, rx_err, dev->net, "no read resubmitted\n");
 }
 
-static void intr_complete (struct urb *urb)
+static void intr_complete(struct urb *urb)
 {
 	struct usbnet	*dev = urb->context;
 	int		status = urb->status;
 
 	switch (status) {
-	/* success */
+		/* success */
 	case 0:
 		dev->driver_info->status(dev, urb);
 		break;
 
-	/* software-driven interface shutdown */
+		/* software-driven interface shutdown */
 	case -ENOENT:		/* urb killed */
 	case -ESHUTDOWN:	/* hardware gone */
 		netif_dbg(dev, ifdown, dev->net,
 			  "intr shutdown, code %d\n", status);
 		return;
 
-	/* NOTE:  not throttling like RX/TX, since this endpoint
-	 * already polls infrequently
-	 */
+		/* NOTE:  not throttling like RX/TX, since this endpoint
+		 * already polls infrequently
+		 */
 	default:
 		netdev_dbg(dev->net, "intr status %d\n", status);
 		break;
 	}
 
-	if (!netif_running (dev->net))
+	if (!netif_running(dev->net))
 		return;
 
 	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
-	status = usb_submit_urb (urb, GFP_ATOMIC);
+	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status != 0)
 		netif_err(dev, timer, dev->net,
 			  "intr resubmit --> %d\n", status);
@@ -568,15 +569,15 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
 
 /*-------------------------------------------------------------------------*/
 
-// unlink pending rx/tx; completion handlers do all other cleanup
+/* unlink pending rx/tx; completion handlers do all other cleanup */
 
-static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
+static int unlink_urbs(struct usbnet *dev, struct sk_buff_head *q)
 {
 	unsigned long		flags;
 	struct sk_buff		*skb, *skbnext;
 	int			count = 0;
 
-	spin_lock_irqsave (&q->lock, flags);
+	spin_lock_irqsave(&q->lock, flags);
 	skb_queue_walk_safe(q, skb, skbnext) {
 		struct skb_data		*entry;
 		struct urb		*urb;
@@ -585,25 +586,27 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 		entry = (struct skb_data *) skb->cb;
 		urb = entry->urb;
 
-		// during some PM-driven resume scenarios,
-		// these (async) unlinks complete immediately
-		retval = usb_unlink_urb (urb);
+		/* during some PM-driven resume scenarios,
+		 * these (async) unlinks complete immediately
+		 */
+		retval = usb_unlink_urb(urb);
 		if (retval != -EINPROGRESS && retval != 0)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
 	}
-	spin_unlock_irqrestore (&q->lock, flags);
+	spin_unlock_irqrestore(&q->lock, flags);
 	return count;
 }
 
-// Flush all pending rx urbs
-// minidrivers may need to do this when the MTU changes
+/* Flush all pending rx urbs
+ * minidrivers may need to do this when the MTU changes
+ */
 
 void usbnet_unlink_rx_urbs(struct usbnet *dev)
 {
 	if (netif_running(dev->net)) {
-		(void) unlink_urbs (dev, &dev->rxq);
+		(void)unlink_urbs(dev, &dev->rxq);
 		tasklet_schedule(&dev->bh);
 	}
 }
@@ -611,7 +614,7 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
 
 /*-------------------------------------------------------------------------*/
 
-// precondition: never called in_interrupt
+/* precondition: never called in_interrupt */
 static void usbnet_terminate_urbs(struct usbnet *dev)
 {
 	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(unlink_wakeup);
@@ -622,30 +625,29 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 	add_wait_queue(&unlink_wakeup, &wait);
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	dev->wait = &unlink_wakeup;
-	temp = unlink_urbs(dev, &dev->txq) +
-		unlink_urbs(dev, &dev->rxq);
+	temp = unlink_urbs(dev, &dev->txq) + unlink_urbs(dev, &dev->rxq);
 
 	/* maybe wait for deletions to finish. */
-	while (!skb_queue_empty(&dev->rxq)
-		&& !skb_queue_empty(&dev->txq)
-		&& !skb_queue_empty(&dev->done)) {
-			schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			netif_dbg(dev, ifdown, dev->net,
-				  "waited for %d urb completions\n", temp);
+	while (!skb_queue_empty(&dev->rxq) &&
+	       !skb_queue_empty(&dev->txq) &&
+	       !skb_queue_empty(&dev->done)) {
+		schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		netif_dbg(dev, ifdown, dev->net,
+			  "waited for %d urb completions\n", temp);
 	}
 	set_current_state(TASK_RUNNING);
 	dev->wait = NULL;
 	remove_wait_queue(&unlink_wakeup, &wait);
 }
 
-int usbnet_stop (struct net_device *net)
+int usbnet_stop(struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	struct driver_info	*info = dev->driver_info;
 	int			retval;
 
-	netif_stop_queue (net);
+	netif_stop_queue(net);
 
 	netif_info(dev, ifdown, dev->net,
 		   "stop stats: rx/tx %lu/%lu, errs %lu/%lu\n",
@@ -676,8 +678,8 @@ int usbnet_stop (struct net_device *net)
 	 * else workers could deadlock; so make workers a NOP.
 	 */
 	dev->flags = 0;
-	del_timer_sync (&dev->delay);
-	tasklet_kill (&dev->bh);
+	del_timer_sync(&dev->delay);
+	tasklet_kill(&dev->bh);
 	if (info->manage_power)
 		info->manage_power(dev, 0);
 	else
@@ -689,17 +691,18 @@ EXPORT_SYMBOL_GPL(usbnet_stop);
 
 /*-------------------------------------------------------------------------*/
 
-// posts reads, and enables write queuing
-
-// precondition: never called in_interrupt
+/* posts reads, and enables write queuing
+ * precondition: never called in_interrupt
+ */
 
-int usbnet_open (struct net_device *net)
+int usbnet_open(struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			retval;
 	struct driver_info	*info = dev->driver_info;
 
-	if ((retval = usb_autopm_get_interface(dev->intf)) < 0) {
+	retval = usb_autopm_get_interface(dev->intf);
+	if (retval < 0) {
 		netif_info(dev, ifup, dev->net,
 			   "resumption fail (%d) usbnet usb-%s-%s, %s\n",
 			   retval,
@@ -709,8 +712,8 @@ int usbnet_open (struct net_device *net)
 		goto done_nopm;
 	}
 
-	// put into "known safe" state
-	if (info->reset && (retval = info->reset (dev)) < 0) {
+	/* put into "known safe" state */
+	if (info->reset && (retval = info->reset(dev)) < 0) {
 		netif_info(dev, ifup, dev->net,
 			   "open reset fail (%d) usbnet usb-%s-%s, %s\n",
 			   retval,
@@ -720,15 +723,15 @@ int usbnet_open (struct net_device *net)
 		goto done;
 	}
 
-	// insist peer be connected
-	if (info->check_connect && (retval = info->check_connect (dev)) < 0) {
+	/* insist peer be connected */
+	if (info->check_connect && (retval = info->check_connect(dev)) < 0) {
 		netif_dbg(dev, ifup, dev->net, "can't open; %d\n", retval);
 		goto done;
 	}
 
 	/* start any status interrupt transfer */
 	if (dev->interrupt) {
-		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
+		retval = usb_submit_urb(dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
 				  "intr submit %d\n", retval);
@@ -736,7 +739,7 @@ int usbnet_open (struct net_device *net)
 		}
 	}
 
-	netif_start_queue (net);
+	netif_start_queue(net);
 	netif_info(dev, ifup, dev->net,
 		   "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
 		   (int)RX_QLEN(dev), (int)TX_QLEN(dev),
@@ -748,8 +751,8 @@ int usbnet_open (struct net_device *net)
 		   (dev->driver_info->flags & FLAG_FRAMING_AX) ? "ASIX" :
 		   "simple");
 
-	// delay posting reads until we're fully open
-	tasklet_schedule (&dev->bh);
+	/* delay posting reads until we're fully open */
+	tasklet_schedule(&dev->bh);
 	if (info->manage_power) {
 		retval = info->manage_power(dev, 1);
 		if (retval < 0)
@@ -771,7 +774,7 @@ EXPORT_SYMBOL_GPL(usbnet_open);
  * they'll probably want to use this base set.
  */
 
-int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
+int usbnet_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 
@@ -782,7 +785,7 @@ int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL_GPL(usbnet_get_settings);
 
-int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd)
+int usbnet_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 	int retval;
@@ -801,13 +804,13 @@ int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL_GPL(usbnet_set_settings);
 
-u32 usbnet_get_link (struct net_device *net)
+u32 usbnet_get_link(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
 
 	/* If a check_connect is defined, return its result */
 	if (dev->driver_info->check_connect)
-		return dev->driver_info->check_connect (dev) == 0;
+		return dev->driver_info->check_connect(dev) == 0;
 
 	/* if the device has mii operations, use those */
 	if (dev->mii.mdio_read)
@@ -829,19 +832,19 @@ int usbnet_nway_reset(struct net_device *net)
 }
 EXPORT_SYMBOL_GPL(usbnet_nway_reset);
 
-void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvinfo *info)
+void usbnet_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 {
 	struct usbnet *dev = netdev_priv(net);
 
-	strncpy (info->driver, dev->driver_name, sizeof info->driver);
-	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
-	strncpy (info->fw_version, dev->driver_info->description,
-		sizeof info->fw_version);
-	usb_make_path (dev->udev, info->bus_info, sizeof info->bus_info);
+	strncpy(info->driver, dev->driver_name, sizeof(info->driver));
+	strncpy(info->version, DRIVER_VERSION, sizeof(info->version));
+	strncpy(info->fw_version, dev->driver_info->description,
+		sizeof(info->fw_version));
+	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
 }
 EXPORT_SYMBOL_GPL(usbnet_get_drvinfo);
 
-u32 usbnet_get_msglevel (struct net_device *net)
+u32 usbnet_get_msglevel(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
 
@@ -849,7 +852,7 @@ u32 usbnet_get_msglevel (struct net_device *net)
 }
 EXPORT_SYMBOL_GPL(usbnet_get_msglevel);
 
-void usbnet_set_msglevel (struct net_device *net, u32 level)
+void usbnet_set_msglevel(struct net_device *net, u32 level)
 {
 	struct usbnet *dev = netdev_priv(net);
 
@@ -876,90 +879,92 @@ static const struct ethtool_ops usbnet_ethtool_ops = {
  * especially now that control transfers can be queued.
  */
 static void
-kevent (struct work_struct *work)
+kevent(struct work_struct *work)
 {
-	struct usbnet		*dev =
-		container_of(work, struct usbnet, kevent);
-	int			status;
+	struct usbnet	*dev = container_of(work, struct usbnet, kevent);
+	int		status;
 
 	/* usb_clear_halt() needs a thread context */
-	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
-		unlink_urbs (dev, &dev->txq);
+	if (test_bit(EVENT_TX_HALT, &dev->flags)) {
+		unlink_urbs(dev, &dev->txq);
 		status = usb_autopm_get_interface(dev->intf);
 		if (status < 0)
 			goto fail_pipe;
-		status = usb_clear_halt (dev->udev, dev->out);
+		status = usb_clear_halt(dev->udev, dev->out);
 		usb_autopm_put_interface(dev->intf);
 		if (status < 0 &&
 		    status != -EPIPE &&
 		    status != -ESHUTDOWN) {
-			if (netif_msg_tx_err (dev))
+			if (netif_msg_tx_err(dev))
 fail_pipe:
-				netdev_err(dev->net, "can't clear tx halt, status %d\n",
+				netdev_err(dev->net,
+					   "can't clear tx halt, status %d\n",
 					   status);
 		} else {
-			clear_bit (EVENT_TX_HALT, &dev->flags);
+			clear_bit(EVENT_TX_HALT, &dev->flags);
 			if (status != -ESHUTDOWN)
-				netif_wake_queue (dev->net);
+				netif_wake_queue(dev->net);
 		}
 	}
-	if (test_bit (EVENT_RX_HALT, &dev->flags)) {
-		unlink_urbs (dev, &dev->rxq);
+	if (test_bit(EVENT_RX_HALT, &dev->flags)) {
+		unlink_urbs(dev, &dev->rxq);
 		status = usb_autopm_get_interface(dev->intf);
 		if (status < 0)
 			goto fail_halt;
-		status = usb_clear_halt (dev->udev, dev->in);
+		status = usb_clear_halt(dev->udev, dev->in);
 		usb_autopm_put_interface(dev->intf);
 		if (status < 0 &&
 		    status != -EPIPE &&
 		    status != -ESHUTDOWN) {
-			if (netif_msg_rx_err (dev))
+			if (netif_msg_rx_err(dev))
 fail_halt:
-				netdev_err(dev->net, "can't clear rx halt, status %d\n",
+				netdev_err(dev->net,
+					   "can't clear rx halt, status %d\n",
 					   status);
 		} else {
-			clear_bit (EVENT_RX_HALT, &dev->flags);
-			tasklet_schedule (&dev->bh);
+			clear_bit(EVENT_RX_HALT, &dev->flags);
+			tasklet_schedule(&dev->bh);
 		}
 	}
 
 	/* tasklet could resubmit itself forever if memory is tight */
-	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
+	if (test_bit(EVENT_RX_MEMORY, &dev->flags)) {
 		struct urb	*urb = NULL;
 		int resched = 1;
 
-		if (netif_running (dev->net))
-			urb = usb_alloc_urb (0, GFP_KERNEL);
+		if (netif_running(dev->net))
+			urb = usb_alloc_urb(0, GFP_KERNEL);
 		else
-			clear_bit (EVENT_RX_MEMORY, &dev->flags);
+			clear_bit(EVENT_RX_MEMORY, &dev->flags);
 		if (urb != NULL) {
-			clear_bit (EVENT_RX_MEMORY, &dev->flags);
+			clear_bit(EVENT_RX_MEMORY, &dev->flags);
 			status = usb_autopm_get_interface(dev->intf);
 			if (status < 0) {
 				usb_free_urb(urb);
 				goto fail_lowmem;
 			}
-			if (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
+			if (rx_submit(dev, urb, GFP_KERNEL) == -ENOLINK)
 				resched = 0;
 			usb_autopm_put_interface(dev->intf);
 fail_lowmem:
 			if (resched)
-				tasklet_schedule (&dev->bh);
+				tasklet_schedule(&dev->bh);
 		}
 	}
 
-	if (test_bit (EVENT_LINK_RESET, &dev->flags)) {
+	if (test_bit(EVENT_LINK_RESET, &dev->flags)) {
 		struct driver_info	*info = dev->driver_info;
 		int			retval = 0;
 
-		clear_bit (EVENT_LINK_RESET, &dev->flags);
+		clear_bit(EVENT_LINK_RESET, &dev->flags);
 		status = usb_autopm_get_interface(dev->intf);
 		if (status < 0)
 			goto skip_reset;
-		if(info->link_reset && (retval = info->link_reset(dev)) < 0) {
+		if (info->link_reset && (retval = info->link_reset(dev)) < 0) {
 			usb_autopm_put_interface(dev->intf);
 skip_reset:
-			netdev_info(dev->net, "link reset failed (%d) usbnet usb-%s-%s, %s\n",
+			netdev_info(dev->net,
+				    "link reset failed (%d) usbnet usb-%s-%s, %s\n",
 				    retval,
 				    dev->udev->bus->bus_name,
 				    dev->udev->devpath,
@@ -970,15 +975,16 @@ skip_reset:
 	}
 
 	if (dev->flags)
-		netdev_dbg(dev->net, "kevent done, flags = 0x%lx\n", dev->flags);
+		netdev_dbg(dev->net, "kevent done, flags = 0x%lx\n",
+			   dev->flags);
 }
 
 /*-------------------------------------------------------------------------*/
 
-static void tx_complete (struct urb *urb)
+static void tx_complete(struct urb *urb)
 {
-	struct sk_buff		*skb = (struct sk_buff *) urb->context;
-	struct skb_data		*entry = (struct skb_data *) skb->cb;
+	struct sk_buff		*skb = (struct sk_buff *)urb->context;
+	struct skb_data		*entry = (struct skb_data *)skb->cb;
 	struct usbnet		*dev = entry->dev;
 
 	if (urb->status == 0) {
@@ -990,27 +996,29 @@ static void tx_complete (struct urb *urb)
 
 		switch (urb->status) {
 		case -EPIPE:
-			usbnet_defer_kevent (dev, EVENT_TX_HALT);
+			usbnet_defer_kevent(dev, EVENT_TX_HALT);
 			break;
 
-		/* software-driven interface shutdown */
-		case -ECONNRESET:		// async unlink
-		case -ESHUTDOWN:		// hardware gone
+			/* software-driven interface shutdown */
+		case -ECONNRESET:		/* async unlink */
+		case -ESHUTDOWN:		/* hardware gone */
 			break;
 
-		// like rx, tx gets controller i/o faults during khubd delays
-		// and so it uses the same throttling mechanism.
+			/* like rx, tx gets controller i/o faults during
+			 * khubd delays and so it uses the same throttling
+			 * mechanism.
+			 */
 		case -EPROTO:
 		case -ETIME:
 		case -EILSEQ:
 			usb_mark_last_busy(dev->udev);
-			if (!timer_pending (&dev->delay)) {
-				mod_timer (&dev->delay,
-					jiffies + THROTTLE_JIFFIES);
+			if (!timer_pending(&dev->delay)) {
+				mod_timer(&dev->delay,
+					  jiffies + THROTTLE_JIFFIES);
 				netif_dbg(dev, link, dev->net,
 					  "tx throttle %d\n", urb->status);
 			}
-			netif_stop_queue (dev->net);
+			netif_stop_queue(dev->net);
 			break;
 		default:
 			netif_dbg(dev, tx_err, dev->net,
@@ -1027,21 +1035,21 @@ static void tx_complete (struct urb *urb)
 
 /*-------------------------------------------------------------------------*/
 
-void usbnet_tx_timeout (struct net_device *net)
+void usbnet_tx_timeout(struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 
-	unlink_urbs (dev, &dev->txq);
-	tasklet_schedule (&dev->bh);
+	unlink_urbs(dev, &dev->txq);
+	tasklet_schedule(&dev->bh);
 
-	// FIXME: device recovery -- reset?
+	/* FIXME: device recovery -- reset? */
 }
 EXPORT_SYMBOL_GPL(usbnet_tx_timeout);
 
 /*-------------------------------------------------------------------------*/
 
-netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
-				     struct net_device *net)
+netdev_tx_t usbnet_start_xmit(struct sk_buff *skb,
+			      struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			length;
@@ -1051,10 +1059,11 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	unsigned long		flags;
 	int retval;
 
-	// some devices want funky USB-level framing, for
-	// win32 driver (usually) and/or hardware quirks
+	/* some devices want funky USB-level framing, for
+	 * win32 driver (usually) and/or hardware quirks
+	 */
 	if (info->tx_fixup) {
-		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
+		skb = info->tx_fixup(dev, skb, GFP_ATOMIC);
 		if (!skb) {
 			if (netif_msg_tx_err(dev)) {
 				netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
@@ -1067,19 +1076,20 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	}
 	length = skb->len;
 
-	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
 		netif_dbg(dev, tx_err, dev->net, "no urb\n");
 		goto drop;
 	}
 
-	entry = (struct skb_data *) skb->cb;
+	entry = (struct skb_data *)skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
 	entry->state = tx_start;
 	entry->length = length;
 
-	usb_fill_bulk_urb (urb, dev->udev, dev->out,
-			skb->data, skb->len, tx_complete, skb);
+	usb_fill_bulk_urb(urb, dev->udev, dev->out,
+			  skb->data, skb->len, tx_complete, skb);
 
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
@@ -1121,10 +1131,10 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	}
 #endif
 
-	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
+	switch ((retval = usb_submit_urb(urb, GFP_ATOMIC))) {
 	case -EPIPE:
-		netif_stop_queue (net);
-		usbnet_defer_kevent (dev, EVENT_TX_HALT);
+		netif_stop_queue(net);
+		usbnet_defer_kevent(dev, EVENT_TX_HALT);
 		usb_autopm_put_interface_async(dev->intf);
 		break;
 	default:
@@ -1134,11 +1144,11 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		break;
 	case 0:
 		net->trans_start = jiffies;
-		__skb_queue_tail (&dev->txq, skb);
-		if (dev->txq.qlen >= TX_QLEN (dev))
-			netif_stop_queue (net);
+		__skb_queue_tail(&dev->txq, skb);
+		if (dev->txq.qlen >= TX_QLEN(dev))
+			netif_stop_queue(net);
 	}
-	spin_unlock_irqrestore (&dev->txq.lock, flags);
+	spin_unlock_irqrestore(&dev->txq.lock, flags);
 
 	if (retval) {
 		netif_dbg(dev, tx_err, dev->net, "drop, code %d\n", retval);
@@ -1146,8 +1156,8 @@ drop:
 		dev->net->stats.tx_dropped++;
 not_drop:
 		if (skb)
-			dev_kfree_skb_any (skb);
-		usb_free_urb (urb);
+			dev_kfree_skb_any(skb);
+		usb_free_urb(urb);
 	} else
 		netif_dbg(dev, tx_queued, dev->net,
 			  "> tx, len %d, type 0x%x\n", length, skb->protocol);
@@ -1160,54 +1170,54 @@ EXPORT_SYMBOL_GPL(usbnet_start_xmit);
 
 /*-------------------------------------------------------------------------*/
 
-// tasklet (work deferred from completions, in_irq) or timer
+/* tasklet (work deferred from completions, in_irq) or timer */
 
-static void usbnet_bh (unsigned long param)
+static void usbnet_bh(unsigned long param)
 {
-	struct usbnet		*dev = (struct usbnet *) param;
+	struct usbnet		*dev = (struct usbnet *)param;
 	struct sk_buff		*skb;
 	struct skb_data		*entry;
 
-	while ((skb = skb_dequeue (&dev->done))) {
-		entry = (struct skb_data *) skb->cb;
+	while ((skb = skb_dequeue(&dev->done))) {
+		entry = (struct skb_data *)skb->cb;
 		switch (entry->state) {
 		case rx_done:
 			entry->state = rx_cleanup;
-			rx_process (dev, skb);
+			rx_process(dev, skb);
 			continue;
 		case tx_done:
 		case rx_cleanup:
-			usb_free_urb (entry->urb);
-			dev_kfree_skb (skb);
+			usb_free_urb(entry->urb);
+			dev_kfree_skb(skb);
 			continue;
 		default:
-			netdev_dbg(dev->net, "bogus skb state %d\n", entry->state);
+			netdev_dbg(dev->net, "bogus skb state %d\n",
+				   entry->state);
 		}
 	}
 
-	// waiting for all pending urbs to complete?
+	/* waiting for all pending urbs to complete? */
 	if (dev->wait) {
-		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
-			wake_up (dev->wait);
-		}
-
-	// or are we maybe short a few urbs?
-	} else if (netif_running (dev->net) &&
-		   netif_device_present (dev->net) &&
-		   !timer_pending (&dev->delay) &&
-		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
+		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0)
+			wake_up(dev->wait);
+
+		/* or are we maybe short a few urbs? */
+	} else if (netif_running(dev->net) &&
+		   netif_device_present(dev->net) &&
+		   !timer_pending(&dev->delay) &&
+		   !test_bit(EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
-		int	qlen = RX_QLEN (dev);
+		int	qlen = RX_QLEN(dev);
 
 		if (temp < qlen) {
 			struct urb	*urb;
 			int		i;
 
-			// don't refill the queue all at once
+			/* don't refill the queue all at once */
 			for (i = 0; i < 10 && dev->rxq.qlen < qlen; i++) {
-				urb = usb_alloc_urb (0, GFP_ATOMIC);
+				urb = usb_alloc_urb(0, GFP_ATOMIC);
 				if (urb != NULL) {
-					if (rx_submit (dev, urb, GFP_ATOMIC) ==
+					if (rx_submit(dev, urb, GFP_ATOMIC) ==
 					    -ENOLINK)
 						return;
 				}
@@ -1217,10 +1227,10 @@ static void usbnet_bh (unsigned long param)
 					  "rxqlen %d --> %d\n",
 					  temp, dev->rxq.qlen);
 			if (dev->rxq.qlen < qlen)
-				tasklet_schedule (&dev->bh);
+				tasklet_schedule(&dev->bh);
 		}
-		if (dev->txq.qlen < TX_QLEN (dev))
-			netif_wake_queue (dev->net);
+		if (dev->txq.qlen < TX_QLEN(dev))
+			netif_wake_queue(dev->net);
 	}
 }
 
@@ -1231,9 +1241,9 @@ static void usbnet_bh (unsigned long param)
  *
  *-------------------------------------------------------------------------*/
 
-// precondition: never called in_interrupt
+/* precondition: never called in_interrupt */
 
-void usbnet_disconnect (struct usb_interface *intf)
+void usbnet_disconnect(struct usb_interface *intf)
 {
 	struct usbnet		*dev;
 	struct usb_device	*xdev;
@@ -1244,7 +1254,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	if (!dev)
 		return;
 
-	xdev = interface_to_usbdev (intf);
+	xdev = interface_to_usbdev(intf);
 
 	netif_info(dev, probe, dev->net, "unregister '%s' usb-%s-%s, %s\n",
 		   intf->dev.driver->name,
@@ -1252,15 +1262,15 @@ void usbnet_disconnect (struct usb_interface *intf)
 		   dev->driver_info->description);
 
 	net = dev->net;
-	unregister_netdev (net);
+	unregister_netdev(net);
 
 	cancel_work_sync(&dev->kevent);
 
 	if (dev->driver_info->unbind)
-		dev->driver_info->unbind (dev, intf);
+		dev->driver_info->unbind(dev, intf);
 
 	free_netdev(net);
-	usb_put_dev (xdev);
+	usb_put_dev(xdev);
 }
 EXPORT_SYMBOL_GPL(usbnet_disconnect);
 
@@ -1270,13 +1280,13 @@ static const struct net_device_ops usbnet_netdev_ops = {
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
 /*-------------------------------------------------------------------------*/
 
-// precondition: never called in_interrupt
+/* precondition: never called in_interrupt */
 
 static struct device_type wlan_type = {
 	.name	= "wlan",
@@ -1287,7 +1297,7 @@ static struct device_type wwan_type = {
 };
 
 int
-usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
+usbnet_probe(struct usb_interface *udev, const struct usb_device_id *prod)
 {
 	struct usbnet			*dev;
 	struct net_device		*net;
@@ -1296,7 +1306,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	struct usb_device		*xdev;
 	int				status;
 	const char			*name;
-	struct usb_driver 	*driver = to_usb_driver(udev->dev.driver);
+	struct usb_driver	*driver = to_usb_driver(udev->dev.driver);
 
 	/* usbnet already took usb runtime pm, so have to enable the feature
 	 * for usb interface, otherwise usb_autopm_get_interface may return
@@ -1308,22 +1318,22 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	}
 
 	name = udev->dev.driver->name;
-	info = (struct driver_info *) prod->driver_info;
+	info = (struct driver_info *)prod->driver_info;
 	if (!info) {
-		dev_dbg (&udev->dev, "blacklisted by %s\n", name);
+		dev_dbg(&udev->dev, "blacklisted by %s\n", name);
 		return -ENODEV;
 	}
-	xdev = interface_to_usbdev (udev);
+	xdev = interface_to_usbdev(udev);
 	interface = udev->cur_altsetting;
 
-	usb_get_dev (xdev);
+	usb_get_dev(xdev);
 
 	status = -ENOMEM;
 
-	// set up our own records
+	/* set up our own records */
 	net = alloc_etherdev(sizeof(*dev));
 	if (!net) {
-		dbg ("can't kmalloc dev");
+		dbg("can't kmalloc dev");
 		goto out;
 	}
 
@@ -1335,33 +1345,34 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->intf = udev;
 	dev->driver_info = info;
 	dev->driver_name = name;
-	dev->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
-				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
-	skb_queue_head_init (&dev->rxq);
-	skb_queue_head_init (&dev->txq);
-	skb_queue_head_init (&dev->done);
+	dev->msg_enable = netif_msg_init(msg_level, NETIF_MSG_DRV
+					 | NETIF_MSG_PROBE | NETIF_MSG_LINK);
+	skb_queue_head_init(&dev->rxq);
+	skb_queue_head_init(&dev->txq);
+	skb_queue_head_init(&dev->done);
 	skb_queue_head_init(&dev->rxq_pause);
 	dev->bh.func = usbnet_bh;
-	dev->bh.data = (unsigned long) dev;
-	INIT_WORK (&dev->kevent, kevent);
+	dev->bh.data = (unsigned long)dev;
+	INIT_WORK(&dev->kevent, kevent);
 	init_usb_anchor(&dev->deferred);
 	dev->delay.function = usbnet_bh;
-	dev->delay.data = (unsigned long) dev;
-	init_timer (&dev->delay);
-	mutex_init (&dev->phy_mutex);
+	dev->delay.data = (unsigned long)dev;
+	init_timer(&dev->delay);
+	mutex_init(&dev->phy_mutex);
 
 	dev->net = net;
-	strcpy (net->name, "usb%d");
-	memcpy (net->dev_addr, node_id, sizeof node_id);
+	strcpy(net->name, "usb%d");
+	memcpy(net->dev_addr, node_id, sizeof(node_id));
 
 	/* rx and tx sides can use different message sizes;
 	 * bind() should set rx_urb_size in that case.
 	 */
 	dev->hard_mtu = net->mtu + net->hard_header_len;
 #if 0
-// dma_supported() is deeply broken on almost all architectures
-	// possible with some EHCI controllers
-	if (dma_supported (&udev->dev, DMA_BIT_MASK(64)))
+	/* dma_supported() is deeply broken on almost all architectures
+	 * possible with some EHCI controllers
+	 */
+	if (dma_supported(&udev->dev, DMA_BIT_MASK(64)))
 		net->features |= NETIF_F_HIGHDMA;
 #endif
 
@@ -1369,20 +1380,22 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
 	net->ethtool_ops = &usbnet_ethtool_ops;
 
-	// allow device-specific bind/init procedures
-	// NOTE net->name still not usable ...
+	/* allow device-specific bind/init procedures
+	 * NOTE net->name still not usable ...
+	 */
 	if (info->bind) {
-		status = info->bind (dev, udev);
+		status = info->bind(dev, udev);
 		if (status < 0)
 			goto out1;
 
-		// heuristic:  "usb%d" for links we know are two-host,
-		// else "eth%d" when there's reasonable doubt.  userspace
-		// can rename the link if it knows better.
+		/* heuristic:  "usb%d" for links we know are two-host,
+		 * else "eth%d" when there's reasonable doubt.  userspace
+		 * can rename the link if it knows better.
+		 */
 		if ((dev->driver_info->flags & FLAG_ETHER) != 0 &&
 		    ((dev->driver_info->flags & FLAG_POINTTOPOINT) == 0 ||
-		     (net->dev_addr [0] & 0x02) == 0))
-			strcpy (net->name, "eth%d");
+		     (net->dev_addr[0] & 0x02) == 0))
+			strcpy(net->name, "eth%d");
 		/* WLAN devices should always be named "wlan%d" */
 		if ((dev->driver_info->flags & FLAG_WLAN) != 0)
 			strcpy(net->name, "wlan%d");
@@ -1394,33 +1407,33 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		if (net->mtu > (dev->hard_mtu - net->hard_header_len))
 			net->mtu = dev->hard_mtu - net->hard_header_len;
 	} else if (!info->in || !info->out)
-		status = usbnet_get_endpoints (dev, udev);
+		status = usbnet_get_endpoints(dev, udev);
 	else {
-		dev->in = usb_rcvbulkpipe (xdev, info->in);
-		dev->out = usb_sndbulkpipe (xdev, info->out);
+		dev->in = usb_rcvbulkpipe(xdev, info->in);
+		dev->out = usb_sndbulkpipe(xdev, info->out);
 		if (!(info->flags & FLAG_NO_SETINT))
-			status = usb_set_interface (xdev,
-				interface->desc.bInterfaceNumber,
-				interface->desc.bAlternateSetting);
+			status = usb_set_interface(xdev,
+					interface->desc.bInterfaceNumber,
+					interface->desc.bAlternateSetting);
 		else
 			status = 0;
 
 	}
 	if (status >= 0 && dev->status)
-		status = init_status (dev, udev);
+		status = init_status(dev, udev);
 	if (status < 0)
 		goto out3;
 
 	if (!dev->rx_urb_size)
 		dev->rx_urb_size = dev->hard_mtu;
-	dev->maxpacket = usb_maxpacket (dev->udev, dev->out, 1);
+	dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
 
 	if ((dev->driver_info->flags & FLAG_WLAN) != 0)
 		SET_NETDEV_DEVTYPE(net, &wlan_type);
 	if ((dev->driver_info->flags & FLAG_WWAN) != 0)
 		SET_NETDEV_DEVTYPE(net, &wwan_type);
 
-	status = register_netdev (net);
+	status = register_netdev(net);
 	if (status)
 		goto out3;
 	netif_info(dev, probe, dev->net,
@@ -1430,10 +1443,10 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		   dev->driver_info->description,
 		   net->dev_addr);
 
-	// ok, it's ready to go.
-	usb_set_intfdata (udev, dev);
+	/* ok, it's ready to go. */
+	usb_set_intfdata(udev, dev);
 
-	netif_device_attach (net);
+	netif_device_attach(net);
 
 	if (dev->driver_info->flags & FLAG_LINK_INTR)
 		netif_carrier_off(net);
@@ -1442,7 +1455,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 out3:
 	if (info->unbind)
-		info->unbind (dev, udev);
+		info->unbind(dev, udev);
 out1:
 	free_netdev(net);
 out:
@@ -1458,7 +1471,7 @@ EXPORT_SYMBOL_GPL(usbnet_probe);
  * resume only when the last interface is resumed
  */
 
-int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
+int usbnet_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
 
@@ -1476,7 +1489,7 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * accelerate emptying of the rx and queues, to avoid
 		 * having everything error out.
 		 */
-		netif_device_detach (dev->net);
+		netif_device_detach(dev->net);
 		usbnet_terminate_urbs(dev);
 		usb_kill_urb(dev->interrupt);
 
@@ -1484,13 +1497,13 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * reattach so runtime management can use and
 		 * wake the device
 		 */
-		netif_device_attach (dev->net);
+		netif_device_attach(dev->net);
 	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_suspend);
 
-int usbnet_resume (struct usb_interface *intf)
+int usbnet_resume(struct usb_interface *intf)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
 	struct sk_buff          *skb;
@@ -1518,7 +1531,7 @@ int usbnet_resume (struct usb_interface *intf)
 		spin_unlock_irq(&dev->txq.lock);
 		if (!(dev->txq.qlen >= TX_QLEN(dev)))
 			netif_start_queue(dev->net);
-		tasklet_schedule (&dev->bh);
+		tasklet_schedule(&dev->bh);
 	}
 	return 0;
 }
-- 
1.7.5.rc3.dirty
