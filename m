From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: [PATCH 2.6.9] skge: netpoll support
Date: Tue, 19 Oct 2004 23:58:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41758E11.2040402@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010106020101040906010301"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010106020101040906010301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,
The attached patch adds netconsole support for sk98lin.

Signed-off-by: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>

--------------010106020101040906010301
Content-Type: text/plain;
 name="sk98lin-netpoll.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk98lin-netpoll.diff"

diff -Nurp linux-2.6.9/drivers/net/sk98lin/skge.c linux-2.6.9-mich/drivers/net/sk98lin/skge.c
--- linux-2.6.9/drivers/net/sk98lin/skge.c	2004-10-18 23:53:22.000000000 +0200
+++ linux-2.6.9-mich/drivers/net/sk98lin/skge.c	2004-10-19 23:53:39.621533536 +0200
@@ -1126,6 +1126,24 @@ SK_U32		IntSrc;		/* interrupts source re
 		return SkIsrRetHandled;
 } /* SkGeIsrOnePort */
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/****************************************************************************
+ *
+ * 	SkGePollController - polling receive, for netconsole
+ *
+ * Description:
+ *	Polling receive - used by netconsole and other diagnostic tools
+ *	to allow network i/o with interrupts disabled.
+ *
+ * Returns: N/A
+ */
+static void SkGePollController(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	SkGeIsr(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
 
 /****************************************************************************
  *
@@ -4960,6 +4978,9 @@ static int __devinit skge_probe_one(stru
 	dev->set_mac_address =	&SkGeSetMacAddr;
 	dev->do_ioctl =		&SkGeIoctl;
 	dev->change_mtu =	&SkGeChangeMtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =	&SkGePollController;
+#endif
 	dev->flags &= 		~IFF_RUNNING;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 

--------------010106020101040906010301--
