From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: Re: [PATCH 2.6.9] skge: netpoll support
Date: Wed, 20 Oct 2004 01:11:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41759F34.4030002@stud.feec.vutbr.cz>
References: <41758E11.2040402@stud.feec.vutbr.cz> <20041019220611.GE28904@waste.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000408040800080107000200"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041019220611.GE28904@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000408040800080107000200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Matt Mackall wrote:
> On Tue, Oct 19, 2004 at 11:58:41PM +0200, Michal Schmidt wrote:
> 
>>Hi,
>>The attached patch adds netconsole support for sk98lin.
> 
> 
> Looks good. Would be nice to use actual kernel-doc style documentation
> blocks for new function comments though.
> 

Like this? (attached)

Signed-off-by: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>

--------------000408040800080107000200
Content-Type: text/plain;
 name="sk98lin-netpoll2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk98lin-netpoll2.diff"

diff -Nurp linux-2.6.9/drivers/net/sk98lin/skge.c linux-2.6.9-mich/drivers/net/sk98lin/skge.c
--- linux-2.6.9/drivers/net/sk98lin/skge.c	2004-10-18 23:53:22.000000000 +0200
+++ linux-2.6.9-mich/drivers/net/sk98lin/skge.c	2004-10-20 01:09:07.566181320 +0200
@@ -1126,6 +1126,21 @@ SK_U32		IntSrc;		/* interrupts source re
 		return SkIsrRetHandled;
 } /* SkGeIsrOnePort */
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * SkGePollController - polling receive, for netconsole
+ * @dev: network device
+ *
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
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
@@ -4960,6 +4975,9 @@ static int __devinit skge_probe_one(stru
 	dev->set_mac_address =	&SkGeSetMacAddr;
 	dev->do_ioctl =		&SkGeIoctl;
 	dev->change_mtu =	&SkGeChangeMtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =	&SkGePollController;
+#endif
 	dev->flags &= 		~IFF_RUNNING;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 

--------------000408040800080107000200--
