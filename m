From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] rearrange netdevice structure to save space
Date: Wed, 9 Mar 2005 09:26:28 -0800
Message-ID: <20050309092628.3c9014db@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial reordering of netdevice structure to save four bytes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2005-03-09 09:04:56 -08:00
+++ b/include/linux/netdevice.h	2005-03-09 09:04:56 -08:00
@@ -328,9 +328,7 @@
 	unsigned short		flags;	/* interface flags (a la BSD)	*/
 	unsigned short		gflags;
         unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
-        unsigned short          unused_alignment_fixer; /* Because we need priv_flags,
-                                                         * and we want to be 32-bit aligned.
-                                                         */
+	unsigned short		padded;	/* How much padding added by alloc_netdev() */
 
 	unsigned		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
@@ -487,8 +485,6 @@
 
 	/* class/net/name entry */
 	struct class_device	class_dev;
-	/* how much padding had been added by alloc_netdev() */
-	int padded;
 };
 
 #define	NETDEV_ALIGN		32
