From: Prasanna S Panchamukhi <prasanna@in.ibm.com>
Subject: [4/4]pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Wed, 3 Dec 2003 19:32:14 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031203140214.GC13585@in.ibm.com>
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

Below is the pollcontroller patch for tlan network device driver.
This patch can be applied over 2.6.0-test9-bk25-netdrvr-exp1.patch

diff -urNp linux-netdrvr/drivers/net/tlan.c linux-2.6.0-test10/drivers/net/tlan.c
--- linux-netdrvr/drivers/net/tlan.c	2003-11-24 07:01:12.000000000 +0530
+++ linux-2.6.0-test10/drivers/net/tlan.c	2003-12-04 11:56:16.536491448 +0530
@@ -814,6 +814,14 @@ static void  __init TLan_EisaProbe (void
 
 } /* TLan_EisaProbe */
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void TLan_Poll(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	TLan_HandleInterrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
 
 	
 
@@ -893,6 +901,9 @@ static int TLan_Init( struct net_device 
 	dev->get_stats = &TLan_GetStats;
 	dev->set_multicast_list = &TLan_SetMulticastList;
 	dev->do_ioctl = &TLan_ioctl;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &TLan_Poll;
+#endif
 	dev->tx_timeout = &TLan_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-- 
Thanks & Regards
Prasanna S Panchamukhi
Linux Technology Center
India Software Labs, IBM Bangalore
Ph: 91-80-5044632
