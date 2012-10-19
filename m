From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 01/21] etherdevice: Rename is_<foo>_ether_addr tests to eth_addr_<foo>
Date: Thu, 18 Oct 2012 20:55:32 -0700
Message-ID: <6929e370ccb244a10fffcf66de7408baa55eebad.1350618009.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the ether_addr tests use a similar style to ipv6_<foo> tests.
Add backward compatibility #defines to keep current is_<foo>_ether_addr
code working until completely converted.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index b006ba0..969efa5 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -52,63 +52,63 @@ extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 #define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
 
 /**
- * is_zero_ether_addr - Determine if give Ethernet address is all zeros.
+ * eth_addr_zero - Determine if give Ethernet address is all zeros.
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is all zeroes.
  */
-static inline bool is_zero_ether_addr(const u8 *addr)
+static inline bool eth_addr_zero(const u8 *addr)
 {
 	return !(addr[0] | addr[1] | addr[2] | addr[3] | addr[4] | addr[5]);
 }
 
 /**
- * is_multicast_ether_addr - Determine if the Ethernet address is a multicast.
+ * eth_addr_multicast - Determine if the Ethernet address is a multicast.
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is a multicast address.
  * By definition the broadcast address is also a multicast address.
  */
-static inline bool is_multicast_ether_addr(const u8 *addr)
+static inline bool eth_addr_multicast(const u8 *addr)
 {
 	return 0x01 & addr[0];
 }
 
 /**
- * is_local_ether_addr - Determine if the Ethernet address is locally-assigned one (IEEE 802).
+ * eth_addr_local - Determine if the Ethernet address is locally-assigned one (IEEE 802).
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is a local address.
  */
-static inline bool is_local_ether_addr(const u8 *addr)
+static inline bool eth_addr_local(const u8 *addr)
 {
 	return 0x02 & addr[0];
 }
 
 /**
- * is_broadcast_ether_addr - Determine if the Ethernet address is broadcast
+ * eth_addr_broadcast - Determine if the Ethernet address is broadcast
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is the broadcast address.
  */
-static inline bool is_broadcast_ether_addr(const u8 *addr)
+static inline bool eth_addr_broadcast(const u8 *addr)
 {
 	return (addr[0] & addr[1] & addr[2] & addr[3] & addr[4] & addr[5]) == 0xff;
 }
 
 /**
- * is_unicast_ether_addr - Determine if the Ethernet address is unicast
+ * eth_addr_unicast - Determine if the Ethernet address is unicast
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is a unicast address.
  */
-static inline bool is_unicast_ether_addr(const u8 *addr)
+static inline bool eth_addr_unicast(const u8 *addr)
 {
-	return !is_multicast_ether_addr(addr);
+	return !eth_addr_multicast(addr);
 }
 
 /**
- * is_valid_ether_addr - Determine if the given Ethernet address is valid
+ * eth_addr_valid - Determine if the given Ethernet address is valid
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Check that the Ethernet address (MAC) is not 00:00:00:00:00:00, is not
@@ -116,13 +116,21 @@ static inline bool is_unicast_ether_addr(const u8 *addr)
  *
  * Return true if the address is valid.
  */
-static inline bool is_valid_ether_addr(const u8 *addr)
+static inline bool eth_addr_valid(const u8 *addr)
 {
 	/* FF:FF:FF:FF:FF:FF is a multicast address so we don't need to
 	 * explicitly check for it here. */
-	return !is_multicast_ether_addr(addr) && !is_zero_ether_addr(addr);
+	return !eth_addr_multicast(addr) && !eth_addr_zero(addr);
 }
 
+/* Some #defines to make old is_<foo>_ether_addr tests work for awhile */
+#define is_zero_ether_addr(addr)	eth_addr_zero(addr)
+#define is_multicast_ether_addr(addr)	eth_addr_multicast(addr)
+#define is_local_ether_addr(addr)	eth_addr_local(addr)
+#define is_broadcast_ether_addr(addr)	eth_addr_broadcast(addr)
+#define is_unicast_ether_addr(addr)	eth_addr_unicast(addr)
+#define is_valid_ether_addr(addr)	eth_addr_valid(addr)
+
 /**
  * eth_random_addr - Generate software assigned random Ethernet address
  * @addr: Pointer to a six-byte array containing the Ethernet address
-- 
1.7.8.111.gad25c.dirty
