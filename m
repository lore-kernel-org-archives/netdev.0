From: Prasanna S Panchamukhi <prasanna@in.ibm.com>
Subject: [3/4]pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Wed, 3 Dec 2003 19:30:07 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031203140007.GB13585@in.ibm.com>
Reply-To: prasanna@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, suparna@in.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

Below is the pollcontroller patch for smc ultra net driver.
This patch can be applied over 2.6.0-test9-bk25-netdrvr-exp1.patch

diff -urNp linux.orig/drivers/net/smc-ultra.c linux-2.6.0-test10/drivers/net/smc-ultra.c
--- linux.orig/drivers/net/smc-ultra.c	2003-11-26 03:57:39.000000000 +0530
+++ linux-2.6.0-test10/drivers/net/smc-ultra.c	2003-11-26 03:59:15.630967096 +0530
@@ -121,6 +121,14 @@ MODULE_DEVICE_TABLE(isapnp, ultra_device
 #define ULTRA_IO_EXTENT 32
 #define EN0_ERWCNT		0x08	/* Early receive warning count. */
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void ultra_poll(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	ei_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
 /*	Probe for the Ultra.  This looks like a 8013 with the station
 	address PROM at I/O ports <base>+8 to <base>+13, with a checksum
 	following.
@@ -134,6 +142,9 @@ static int __init do_ultra_probe(struct 
 
 	SET_MODULE_OWNER(dev);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &ultra_poll;
+#endif
 	if (base_addr > 0x1ff)		/* Check a single specified location. */
 		return ultra_probe1(dev, base_addr);
 	else if (base_addr != 0)	/* Don't probe at all. */

-- 
Thanks & Regards
Prasanna S Panchamukhi
Linux Technology Center
India Software Labs, IBM Bangalore
Ph: 91-80-5044632
