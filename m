From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] optimize is_valid_ether_addr
Date: Thu, 10 Mar 2005 15:44:39 -0800
Message-ID: <20050310154439.75f62f22@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Low level optimization of the comparison with zero address.
On most cpu's faster to use unrolled or rather than a loop
and memcmp. This is in the fastpath of bridge forwarding.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/etherdevice.h b/include/linux/etherdevice.h
--- a/include/linux/etherdevice.h	2005-03-10 15:02:04 -08:00
+++ b/include/linux/etherdevice.h	2005-03-10 15:02:04 -08:00
@@ -47,6 +47,15 @@
 }
 
 /**
+ * is_zero_ether_addr - Determine if give Ethernet address is all
+ * zeros.
+ */
+static inline int is_zero_ether_addr(const u8 *addr)
+{
+	return !(addr[0] | addr[1] | addr[2] | addr[3] | addr[4] | addr[5]);
+}
+
+/**
  * is_valid_ether_addr - Determine if the given Ethernet address is valid
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
@@ -56,11 +65,9 @@
  *
  * Return true if the address is valid.
  */
-static inline int is_valid_ether_addr( const u8 *addr )
+static inline int is_valid_ether_addr(const u8 *addr)
 {
-	const char zaddr[6] = {0,};
-
-	return !(addr[0]&1) && memcmp( addr, zaddr, 6);
+	return !(addr[0]&1) && !is_zero_ether_addr(addr);
 }
 
 /**
