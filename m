From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: 3/x: [NETDRV] Add register_ei_netdev
Date: Sat, 29 May 2004 18:41:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529084109.GA13032@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com> <20040520111937.GA21804@gondor.apana.org.au> <20040522074435.GA9628@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040522074435.GA9628@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

Here is the patch that adds register_ei_netdev which lets us get rid of
some of the duplicated printk's in the 8390 drivers.
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/8390.c 1.21 vs edited =====
--- 1.21/drivers/net/8390.c	2004-04-14 04:12:07 +10:00
+++ edited/drivers/net/8390.c	2004-05-29 18:36:06 +10:00
@@ -1033,6 +1033,29 @@
 				ethdev_setup);
 }
 
+/**
+ * register_ei_netdev - register_netdev counterpart for 8390
+ *
+ * Register 8390-specific net_device.
+ */
+int register_ei_netdev(struct net_device *dev)
+{
+	int err;
+	int i;
+
+	err = register_netdev(dev);
+	if (err)
+		return err;
+
+	printk(KERN_INFO "%s: %s at 0x%lx, ",
+		dev->name, ei_status.name, dev->base_addr);
+	for (i = 0; i < ETHER_ADDR_LEN; i++)
+		printk("%2.2x%c", dev->dev_addr[i],
+			i == ETHER_ADDR_LEN - 1 ? ',' : ':');
+	printk(" IRQ %d.\n", dev->irq);
+	return 0;
+}
+
 
 
 
===== drivers/net/8390.h 1.17 vs edited =====
--- 1.17/drivers/net/8390.h	2004-05-25 19:53:07 +10:00
+++ edited/drivers/net/8390.h	2004-05-29 18:17:51 +10:00
@@ -52,6 +52,7 @@
 {
 	return __alloc_ei_netdev(0);
 }
+extern int register_ei_netdev(struct net_device *dev);
 
 /* You have one of these per-board */
 struct ei_device {

--XsQoSWH+UP9D9v3l--
