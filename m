From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] etherdevice.h -- make constant args
Date: Thu, 8 Apr 2004 11:06:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040408110653.003174e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than forcing cast in some new validation code in the bridge;
please fix a couple of inline functions should have "const" on args.

diff -Nru a/include/linux/etherdevice.h b/include/linux/etherdevice.h
--- a/include/linux/etherdevice.h	Thu Apr  8 11:03:52 2004
+++ b/include/linux/etherdevice.h	Thu Apr  8 11:03:52 2004
@@ -40,7 +40,9 @@
 					 unsigned char *haddr);
 
 extern struct net_device *alloc_etherdev(int sizeof_priv);
-static inline void eth_copy_and_sum (struct sk_buff *dest, unsigned char *src, int len, int base)
+static inline void eth_copy_and_sum (struct sk_buff *dest, 
+				     const unsigned char *src, 
+				     int len, int base)
 {
 	memcpy (dest->data, src, len);
 }
@@ -55,7 +57,7 @@
  *
  * Return true if the address is valid.
  */
-static inline int is_valid_ether_addr( u8 *addr )
+static inline int is_valid_ether_addr( const u8 *addr )
 {
 	const char zaddr[6] = {0,};
 
