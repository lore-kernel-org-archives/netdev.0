From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 1/8] Create ipv4_is_<type>(__be32 addr) functions
Date: Thu, 13 Dec 2007 15:38:54 -0800
Message-ID: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe__13128.852324053$1197589229$gmane$org@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765271AbXLMXjt@vger.kernel.org>
Message-Id: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change IPV4 specific macros LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions ipv4_is_<type>(__be32 addr)

Adds type safety and arguably some readability.

Changes since last submission:

Removed ipv4_addr_octets function
Used hex constants
Converted recently added rfc3330 macros

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/in.h |   87 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 74 insertions(+), 13 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index a8f00ca..f8d6073 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -246,21 +246,82 @@ struct sockaddr_in {
 #include <asm/byteorder.h> 
 
 #ifdef __KERNEL__
-/* Some random defines to make it easier in the kernel.. */
-#define LOOPBACK(x)	(((x) & htonl(0xff000000)) == htonl(0x7f000000))
-#define MULTICAST(x)	(((x) & htonl(0xf0000000)) == htonl(0xe0000000))
-#define BADCLASS(x)	(((x) & htonl(0xf0000000)) == htonl(0xf0000000))
-#define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
-#define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
+
+static inline bool ipv4_is_loopback(__be32 addr)
+{
+	return (addr & htonl(0xff000000)) == htonl(0x7f000000);
+}
+
+static inline bool ipv4_is_multicast(__be32 addr)
+{
+	return (addr & htonl(0xf0000000)) == htonl(0xe0000000);
+}
+
+static inline bool ipv4_is_local_multicast(__be32 addr)
+{
+	return (addr & htonl(0xffffff00)) == htonl(0xe0000000);
+}
+
+static inline bool ipv4_is_badclass(__be32 addr)
+{
+	return (addr & htonl(0xf0000000)) == htonl(0xf0000000);
+}
+
+static inline bool ipv4_is_zeronet(__be32 addr)
+{
+	return (addr & htonl(0xff000000)) == htonl(0x00000000);
+}
+
+#define LOOPBACK(x)		ipv4_is_loopback(x)
+#define MULTICAST(x)		ipv4_is_multicast(x)
+#define BADCLASS(x)		ipv4_is_badclass(x)
+#define ZERONET(x)		ipv4_is_zeronet(x)
+#define LOCAL_MCAST(x)		ipv4_is_local_multicast(x)
 
 /* Special-Use IPv4 Addresses (RFC3330) */
-#define PRIVATE_10(x)	(((x) & htonl(0xff000000)) == htonl(0x0A000000))
-#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) == htonl(0xA9FE0000))
-#define PRIVATE_172(x)	(((x) & htonl(0xfff00000)) == htonl(0xAC100000))
-#define TEST_192(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0000200))
-#define ANYCAST_6TO4(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0586300))
-#define PRIVATE_192(x)	(((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
-#define TEST_198(x)	(((x) & htonl(0xfffe0000)) == htonl(0xC6120000))
+
+static inline bool ipv4_is_private_10(__be32 addr)
+{
+	return (addr & htonl(0xff000000)) == htonl(0x0a000000);
+}
+
+static inline bool ipv4_is_private_172(__be32 addr)
+{
+	return (addr & htonl(0xfff00000)) == htonl(0xac100000);
+}
+
+static inline bool ipv4_is_private_192(__be32 addr)
+{
+	return (addr & htonl(0xffff0000)) == htonl(0xc0a80000);
+}
+
+static inline bool ipv4_is_linklocal_169(__be32 addr)
+{
+	return (addr & htonl(0xffff0000)) == htonl(0xa9fe0000);
+}
+
+static inline bool ipv4_is_anycast_6to4(__be32 addr)
+{
+	return (addr & htonl(0xffffff00)) == htonl(0xc0586300);
+}
+
+static inline bool ipv4_is_test_192(__be32 addr)
+{
+	return (addr & htonl(0xffffff00)) == htonl(0xc0000200);
+}
+
+static inline bool ipv4_is_test_198(__be32 addr)
+{
+	return (addr & htonl(0xfffe0000)) == htonl(0xc6120000);
+}
 #endif
 
+#define PRIVATE_10(x)		ipv4_is_private_10(x)
+#define LINKLOCAL_169(x)	ipv4_is_linklocal_169(x)
+#define PRIVATE_172(x)		ipv4_is_private_172(x)
+#define TEST_192(x)		ipv4_is_test_192(x)
+#define ANYCAST_6TO4(x)		ipv4_is_anycast_6to4(x)
+#define PRIVATE_192(x)		ipv4_is_private_192(x)
+#define TEST_198(x)		ipv4_is_test_198(x)
+
 #endif	/* _LINUX_IN_H */
-- 
1.5.3.7.949.g2221a6

