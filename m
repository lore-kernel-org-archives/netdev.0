From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] rtentry->rt_dev is __user
Date: Tue, 22 Jun 2004 15:54:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622155453.564ede17@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The device entry in the route ioctl's needs annotation.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/route.h b/include/linux/route.h
--- a/include/linux/route.h	2004-06-22 15:49:41 -07:00
+++ b/include/linux/route.h	2004-06-22 15:49:41 -07:00
@@ -24,7 +24,7 @@
 #define _LINUX_ROUTE_H
 
 #include <linux/if.h>
-
+#include <linux/compiler.h>
 
 /* This structure gets passed by the SIOCADDRT and SIOCDELRT calls. */
 struct rtentry 
@@ -38,7 +38,7 @@
 	unsigned long	rt_pad3;
 	void		*rt_pad4;
 	short		rt_metric;	/* +1 for binary compatibility!	*/
-	char		*rt_dev;	/* forcing the device at add	*/
+	char __user	*rt_dev;	/* forcing the device at add	*/
 	unsigned long	rt_mtu;		/* per route MTU/Window 	*/
 #ifndef __KERNEL__
 #define rt_mss	rt_mtu			/* Compatibility :-(            */
