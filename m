From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) 8139too -- put back old assert
Date: Wed, 19 Nov 2003 14:36:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119143645.0abc8658.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>,
        OGAWA Hirofumi
 <hirofumi@mail.parknet.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For net-drivers-2.5-exp:
Minimize code changes -- put back assert() macro with similar properties
to the original.  Added unlikely() and KERN_ERR tag.


diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Wed Nov 19 14:33:54 2003
+++ b/drivers/net/8139too.c	Wed Nov 19 14:33:54 2003
@@ -152,7 +152,11 @@
 #ifdef RTL8139_NDEBUG
 #  define assert(expr) do {} while (0)
 #else
-#  define assert(expr) BUG_ON((expr) == 0)
+#  define assert(expr) \
+        if(unlikely(!(expr))) {				        \
+        printk(KERN_ERR "Assertion failed! %s,%s,%s,line=%d\n",	\
+        #expr,__FILE__,__FUNCTION__,__LINE__);		        \
+        }
 #endif
 
 
