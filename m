From: Prasanna S Panchamukhi <prasanna@in.ibm.com>
Subject: [2/4] pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Wed, 3 Dec 2003 19:27:28 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031203135728.GA13585@in.ibm.com>
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

Below is the pollcontroller patch for e1000.
This patch can be applied over 2.6.0-test9-bk25-netdrvr-exp1.patch

diff -urNp linux-netdrvr/drivers/net/e1000/e1000_main.c linux-2.6.0-test10/drivers/net/e1000/e1000_main.c
--- linux-netdrvr/drivers/net/e1000/e1000_main.c	2003-12-04 11:18:03.000000000 +0530
+++ linux-2.6.0-test10/drivers/net/e1000/e1000_main.c	2003-12-04 11:43:35.412199928 +0530
@@ -338,6 +338,15 @@ e1000_reset(struct e1000_adapter *adapte
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void e1000_poll(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	e1000_intr(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 /**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -439,6 +448,9 @@ e1000_probe(struct pci_dev *pdev,
 
 	adapter->bd_number = cards_found;
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = &e1000_poll;
+#endif
 	/* setup the private structure */
 
 	if((err = e1000_sw_init(adapter)))
-- 
Thanks & Regards
Prasanna S Panchamukhi
Linux Technology Center
India Software Labs, IBM Bangalore
Ph: 91-80-5044632
