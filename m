From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] make netdevice.h more non-kernel friendly
Date: Fri, 12 Mar 2004 11:24:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040312112442.3ba028a9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Discovered this trying to build iproute2 with 2.6.4.  The netdevice.h drags
in a lot of stuff that it doesn't need for the non-kernel interface.
Just moving the ifdef up a little got rid of the issues.


diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Fri Mar 12 11:22:02 2004
+++ b/include/linux/netdevice.h	Fri Mar 12 11:22:02 2004
@@ -29,11 +29,11 @@
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
 
+#ifdef __KERNEL__
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
 
-#ifdef __KERNEL__
 #include <linux/config.h>
 #include <linux/device.h>
 #include <linux/percpu.h>
