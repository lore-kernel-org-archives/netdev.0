From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/23) sk98: add netpoll console support
Date: Thu, 11 Nov 2004 15:54:40 -0800
Message-ID: <20041111155440.617bc21f@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add netpoll console support

From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 14:08:32 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 14:08:32 -08:00
@@ -1125,6 +1125,24 @@
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
@@ -4928,6 +4946,9 @@
 	dev->set_mac_address =	&SkGeSetMacAddr;
 	dev->do_ioctl =		&SkGeIoctl;
 	dev->change_mtu =	&SkGeChangeMtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =	&SkGePollController;
+#endif
 	dev->flags &= 		~IFF_RUNNING;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
