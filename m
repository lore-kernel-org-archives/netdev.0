From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tun - don't obscure error return from misc_register
Date: Mon, 15 Mar 2004 10:25:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315102539.0953af7e@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vtun@office.satix.net.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Maxim Krasnyansky
 <maxk@qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When Tun initialization fails it shouldn't obscure the error return, 
There are several reasons it could fail, and when diagnosing user problems
the error code might provide more info.

diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Mon Mar 15 10:13:37 2004
+++ b/drivers/net/tun.c	Mon Mar 15 10:13:37 2004
@@ -609,15 +609,15 @@
 
 int __init tun_init(void)
 {
+	int ret = 0;
+
 	printk(KERN_INFO "Universal TUN/TAP device driver %s " 
 	       "(C)1999-2002 Maxim Krasnyansky\n", TUN_VER);
 
-	if (misc_register(&tun_miscdev)) {
+	ret = misc_register(&tun_miscdev);
+	if (ret)
 		printk(KERN_ERR "tun: Can't register misc device %d\n", TUN_MINOR);
-		return -EIO;
-	}
-
-	return 0;
+	return ret;
 }
 
 void tun_cleanup(void)
