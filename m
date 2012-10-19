From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 15/21] in.h: Rename ipv4_is_<foo> functions to ipv4_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:59 -0700
Message-ID: <e7805590abcf76d60dc0cbeff63c824419726ab4.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the ipv4_is_<foo> tests use a similar style to ipv6_<foo> tests.
Add backward compatibility #defines to keep current ipv4_is_<foo>
code working until completely converted.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/in.h |   40 ++++++++++++++++++++++++++++------------
 1 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 31b4937..2116ce8 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -39,66 +39,82 @@ static inline int proto_ports_offset(int proto)
 	}
 }
 
-static inline bool ipv4_is_loopback(__be32 addr)
+static inline bool ipv4_addr_loopback(__be32 addr)
 {
 	return (addr & htonl(0xff000000)) == htonl(0x7f000000);
 }
 
-static inline bool ipv4_is_multicast(__be32 addr)
+static inline bool ipv4_addr_multicast(__be32 addr)
 {
 	return (addr & htonl(0xf0000000)) == htonl(0xe0000000);
 }
 
-static inline bool ipv4_is_local_multicast(__be32 addr)
+static inline bool ipv4_addr_local_multicast(__be32 addr)
 {
 	return (addr & htonl(0xffffff00)) == htonl(0xe0000000);
 }
 
-static inline bool ipv4_is_lbcast(__be32 addr)
+static inline bool ipv4_addr_lbcast(__be32 addr)
 {
 	/* limited broadcast */
 	return addr == htonl(INADDR_BROADCAST);
 }
 
-static inline bool ipv4_is_zeronet(__be32 addr)
+static inline bool ipv4_addr_zeronet(__be32 addr)
 {
 	return (addr & htonl(0xff000000)) == htonl(0x00000000);
 }
 
 /* Special-Use IPv4 Addresses (RFC3330) */
 
-static inline bool ipv4_is_private_10(__be32 addr)
+static inline bool ipv4_addr_private_10(__be32 addr)
 {
 	return (addr & htonl(0xff000000)) == htonl(0x0a000000);
 }
 
-static inline bool ipv4_is_private_172(__be32 addr)
+static inline bool ipv4_addr_private_172(__be32 addr)
 {
 	return (addr & htonl(0xfff00000)) == htonl(0xac100000);
 }
 
-static inline bool ipv4_is_private_192(__be32 addr)
+static inline bool ipv4_addr_private_192(__be32 addr)
 {
 	return (addr & htonl(0xffff0000)) == htonl(0xc0a80000);
 }
 
-static inline bool ipv4_is_linklocal_169(__be32 addr)
+static inline bool ipv4_addr_linklocal_169(__be32 addr)
 {
 	return (addr & htonl(0xffff0000)) == htonl(0xa9fe0000);
 }
 
-static inline bool ipv4_is_anycast_6to4(__be32 addr)
+static inline bool ipv4_addr_anycast_6to4(__be32 addr)
 {
 	return (addr & htonl(0xffffff00)) == htonl(0xc0586300);
 }
 
-static inline bool ipv4_is_test_192(__be32 addr)
+static inline bool ipv4_addr_test_192(__be32 addr)
 {
 	return (addr & htonl(0xffffff00)) == htonl(0xc0000200);
 }
 
-static inline bool ipv4_is_test_198(__be32 addr)
+static inline bool ipv4_addr_test_198(__be32 addr)
 {
 	return (addr & htonl(0xfffe0000)) == htonl(0xc6120000);
 }
+
+/* Some #defines to make old ipv4_is_<foo> tests work for awhile */
+
+#define ipv4_is_loopback(addr)		ipv4_addr_loopback(addr)
+#define ipv4_is_multicast(addr)		ipv4_addr_multicast(addr)
+#define ipv4_is_local_multicast(addr)	ipv4_addr_local_multicast(addr)
+#define ipv4_is_lbcast(addr)		ipv4_addr_lbcast(addr)
+#define ipv4_is_zeronet(addr)		ipv4_addr_zeronet(addr)
+#define ipv4_is_private_10(addr)	ipv4_addr_private_10(addr)
+#define ipv4_is_private_172(addr)	ipv4_addr_private_172(addr)
+#define ipv4_is_private_192(addr)	ipv4_addr_private_192(addr)
+#define ipv4_is_linklocal_169(addr)	ipv4_addr_linklocal_169(addr)
+#define ipv4_is_anycast_6to4(addr)	ipv4_addr_anycast_6to4(addr)
+#define ipv4_is_test_192(addr)		ipv4_addr_test_192(addr)
+#define ipv4_is_test_198(addr)		ipv4_addr_test_198(addr)
+
 #endif	/* _LINUX_IN_H */
-- 
1.7.8.111.gad25c.dirty
