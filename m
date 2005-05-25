From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH] add is_multicast_ether_addr() in include/linux/etherdevice.h
Date: Wed, 25 May 2005 15:03:00 +1000
Message-ID: <200505251503.01039.michael@ellerman.id.au>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch adds is_multicast_ether_addr() to go along with is_valid_ether_addr()
and friends. It then changes is_valid_ether_addr() to use the new macro, and
fixes up the comment on that function to move implementation details out of
the API doco.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>

Index: veth-dev/include/linux/etherdevice.h
===================================================================
--- veth-dev.orig/include/linux/etherdevice.h
+++ veth-dev/include/linux/etherdevice.h
@@ -56,18 +56,32 @@ static inline int is_zero_ether_addr(con
 }
 
 /**
+ * is_multicast_ether_addr - Determine if the given Ethernet address is a
+ * multicast address.
+ *
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Return true if the address is a multicast address.
+ */
+static inline int is_multicast_ether_addr(const u8 *addr)
+{
+	return addr[0] & 0x01;
+}
+
+/**
  * is_valid_ether_addr - Determine if the given Ethernet address is valid
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Check that the Ethernet address (MAC) is not 00:00:00:00:00:00, is not
- * a multicast address, and is not FF:FF:FF:FF:FF:FF.  The multicast
- * and FF:FF:... tests are combined into the single test "!(addr[0]&1)".
+ * a multicast address, and is not FF:FF:FF:FF:FF:FF.
  *
  * Return true if the address is valid.
  */
 static inline int is_valid_ether_addr(const u8 *addr)
 {
-	return !(addr[0]&1) && !is_zero_ether_addr(addr);
+	/* FF:FF:FF:FF:FF:FF is a multicast address so we don't need to
+	 * explicitly check for it here. */
+	return !is_multicast_ether_addr(addr) && !is_zero_ether_addr(addr);
 }
 
 /**
@@ -83,6 +97,6 @@ static inline void random_ether_addr(u8 
 	addr [0] &= 0xfe;	/* clear multicast bit */
 	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
 }
-#endif
+#endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_ETHERDEVICE_H */
