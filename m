From: Stefan Rompf <srompf@isg.de>
Subject: Patch: netif_carrier_on()/off() for xircom_tulip_cb
Date: Sun, 15 Feb 2004 15:04:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402151504.22648.srompf@isg.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_mx3LA9SAPGssQL/"
Cc: jgarzik@pobox.com, ionut@cs.columbia.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_mx3LA9SAPGssQL/
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

the attached patch against 2.6.3rc2 enables link state notification for 
xircom_tulip_cb. Tested together with my suspend/resume patch, but should be 
independant. Please apply if it looks ok.

Stefan

--Boundary-00=_mx3LA9SAPGssQL/
Content-Type: text/x-diff;
  charset="us-ascii";
  name="xircom_tulip_cb_lw.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="xircom_tulip_cb_lw.diff"

--- drivers/net/tulip/xircom_tulip_cb.c.pm	2004-02-15 13:07:49.000000000 +0100
+++ drivers/net/tulip/xircom_tulip_cb.c	2004-02-15 13:58:06.000000000 +0100
@@ -343,6 +343,7 @@ static void xircom_tx_timeout(struct net
 static void xircom_init_ring(struct net_device *dev);
 static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int xircom_rx(struct net_device *dev);
+static void xircom_media_change(struct net_device *dev);
 static irqreturn_t xircom_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 static int xircom_close(struct net_device *dev);
 static struct net_device_stats *xircom_get_stats(struct net_device *dev);
@@ -789,6 +790,9 @@ xircom_up(struct net_device *dev)
 	/* Tell the net layer we're ready */
 	netif_start_queue (dev);
 
+	/* Check current media state */
+	xircom_media_change(dev);
+
 	if (xircom_debug > 2) {
 		printk(KERN_DEBUG "%s: Done xircom_up(), CSR0 %8.8x, CSR5 %8.8x CSR6 %8.8x.\n",
 			   dev->name, inl(ioaddr + CSR0), inl(ioaddr + CSR5),
@@ -1013,6 +1017,7 @@ static void xircom_media_change(struct n
 		       dev->name,
 		       tp->speed100 ? "100" : "10",
 		       tp->full_duplex ? "full" : "half");
+		netif_carrier_on(dev);
 		newcsr6 = csr6 & ~FullDuplexBit;
 		if (tp->full_duplex)
 			newcsr6 |= FullDuplexBit;
@@ -1020,6 +1025,7 @@ static void xircom_media_change(struct n
 			outl_CSR6(newcsr6, ioaddr + CSR6);
 	} else {
 		printk(KERN_DEBUG "%s: Link is down\n", dev->name);
+		netif_carrier_off(dev);
 	}
 }
 

--Boundary-00=_mx3LA9SAPGssQL/--
