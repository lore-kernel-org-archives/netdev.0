From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c507: convert to use module_param
Date: Mon, 18 Oct 2004 13:07:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018130723.1e63a9c9@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert to use module_param and module_init

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru ua/drivers/net/3c507.c b/drivers/net/3c507.c
--- a/drivers/net/3c507.c	2004-10-18 12:59:50 -07:00
+++ b/drivers/net/3c507.c	2004-10-18 12:59:50 -07:00
@@ -916,21 +916,21 @@
 
 #ifdef MODULE
 static struct net_device *dev_3c507;
-MODULE_PARM(io, "i");
-MODULE_PARM(irq, "i");
+module_param(io, int, 0);
+module_param(irq, int, 0);
 MODULE_PARM_DESC(io, "EtherLink16 I/O base address");
 MODULE_PARM_DESC(irq, "(ignored)");
 
-int init_module(void)
+static int __init el16_init_module(void)
 {
 	if (io == 0)
 		printk("3c507: You should not use auto-probing with insmod!\n");
 	dev_3c507 = el16_probe(-1);
 	return IS_ERR(dev_3c507) ? PTR_ERR(dev_3c507) : 0;
 }
+module_init(el16_init_module);
 
-void
-cleanup_module(void)
+static void __exit el16_cleanup_module(void)
 {
 	struct net_device *dev = dev_3c507;
 	unregister_netdev(dev);
@@ -938,6 +938,8 @@
 	release_region(dev->base_addr, EL16_IO_EXTENT);
 	free_netdev(dev);
 }
+module_exit(el16_cleanup_module);
+
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
 
