From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.9-rc4 1/2] typhoon: use module_param
Date: Mon, 18 Oct 2004 13:46:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018134628.5876a261@zqx3.pdx.osdl.net>
References: <20041015135353.53b1f263@zqx3.pdx.osdl.net>
	<41706186.5090904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41706186.5090904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the diff between my current and your netdev tree.

--- netdev-2.6/drivers/net/typhoon.c	2004-09-22 14:39:42.000000000 -0700
+++ tcp-2.6/drivers/net/typhoon.c	2004-10-18 12:59:51.000000000 -0700
@@ -99,6 +99,7 @@
 #define ERR_PFX			KERN_ERR PFX
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -132,7 +133,7 @@
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
-MODULE_PARM(rx_copybreak, "i");
+module_param(rx_copybreak, int, 0);
 
 #if defined(NETIF_F_TSO) && MAX_SKB_FRAGS > 32
 #warning Typhoon only supports 32 entries in its SG list for TSO, disabling TSO
@@ -1777,7 +1778,7 @@
 typhoon_interrupt(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct typhoon *tp = dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->ioaddr;
 	u32 intr_status;
 
