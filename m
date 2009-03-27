From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] IRDA: donauboe: fix build
Date: Fri, 27 Mar 2009 04:02:27 +0300
Message-ID: <20090327010227.GA2676@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.184]:55933 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934024AbZC0BCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 21:02:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/irda/donauboe.c: In function 'toshoboe_open':
drivers/net/irda/donauboe.c:1660: error: 'struct net_device' has no
member named 'hard_start_xmit'
drivers/net/irda/donauboe.c:1661: error: 'struct net_device' has no
member named 'open'
drivers/net/irda/donauboe.c:1662: error: 'struct net_device' has no
member named 'stop'
drivers/net/irda/donauboe.c:1663: error: 'struct net_device' has no
member named 'do_ioctl'

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/irda/donauboe.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 6f3e7f7..847fa22 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -970,7 +970,7 @@ toshoboe_probe (struct toshoboe_cb *self)
 /* Netdev style code */
 
 /* Transmit something */
-static int
+int
 toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 {
   struct toshoboe_cb *self;
@@ -1145,6 +1145,7 @@ dumpbufs(skb->data,skb->len,'>');
 
   return 0;
 }
+EXPORT_SYMBOL(toshoboe_hard_xmit);
 
 /*interrupt handler */
 static irqreturn_t
@@ -1336,7 +1337,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
 }
 
 
-static int
+int
 toshoboe_net_open (struct net_device *dev)
 {
   struct toshoboe_cb *self;
@@ -1375,8 +1376,9 @@ toshoboe_net_open (struct net_device *dev)
 
   return 0;
 }
+EXPORT_SYMBOL(toshoboe_net_open);
 
-static int
+int
 toshoboe_net_close (struct net_device *dev)
 {
   struct toshoboe_cb *self;
@@ -1405,6 +1407,7 @@ toshoboe_net_close (struct net_device *dev)
 
   return 0;
 }
+EXPORT_SYMBOL(toshoboe_net_close);
 
 /*
  * Function toshoboe_net_ioctl (dev, rq, cmd)
@@ -1412,7 +1415,7 @@ toshoboe_net_close (struct net_device *dev)
  *    Process IOCTL commands for this device
  *
  */
-static int
+int
 toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 {
   struct if_irda_req *irq = (struct if_irda_req *) rq;
@@ -1473,6 +1476,7 @@ out:
   return ret;
 
 }
+EXPORT_SYMBOL(toshoboe_net_ioctl);
 
 MODULE_DESCRIPTION("Toshiba OBOE IrDA Device Driver");
 MODULE_AUTHOR("James McKenzie <james@fishsoup.dhs.org>");
@@ -1657,10 +1661,13 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
 #endif
 
   SET_NETDEV_DEV(dev, &pci_dev->dev);
+
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
   dev->hard_start_xmit = toshoboe_hard_xmit;
   dev->open = toshoboe_net_open;
   dev->stop = toshoboe_net_close;
   dev->do_ioctl = toshoboe_net_ioctl;
+#endif
 
   err = register_netdev(dev);
   if (err)
