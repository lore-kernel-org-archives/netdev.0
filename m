From: Prasanna S Panchamukhi <prasanna@in.ibm.com>
Subject: [1/4]pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Wed, 3 Dec 2003 19:22:16 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031203135216.GA13465@in.ibm.com>
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

Below is the pollcontroller patch for e100. 
This patch can be applied over 2.6.0-test9-bk25-netdrvr-exp1.patch

diff -urNp linux.orig/drivers/net/e100/e100_main.c linux-2.6.0-test10/drivers/net/e100/e100_main.c
--- linux.orig/drivers/net/e100/e100_main.c	2003-11-26 03:57:38.000000000 +0530
+++ linux-2.6.0-test10/drivers/net/e100/e100_main.c	2003-11-26 03:59:15.554978648 +0530
@@ -544,6 +544,22 @@ e100_trigger_SWI(struct e100_private *bd
 	readw(&(bdp->scb->scb_status));	/* flushes last write, read-safe */
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void
+e100_poll(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	e100intr(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static int __devinit
 e100_found1(struct pci_dev *pcid, const struct pci_device_id *ent)
 {
@@ -562,6 +578,9 @@ e100_found1(struct pci_dev *pcid, const 
 
 	SET_MODULE_OWNER(dev);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &e100_poll;
+#endif
 	if (first_time) {
 		first_time = false;
         	printk(KERN_NOTICE "%s - version %s\n",
-- 
Thanks & Regards
Prasanna S Panchamukhi
Linux Technology Center
India Software Labs, IBM Bangalore
Ph: 91-80-5044632
