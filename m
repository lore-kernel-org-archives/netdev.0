From: Joe Perches <joe@perches.com>
Subject: [PATCH] - in.h - IP4_ADDR
Date: Sun, 11 Nov 2007 19:19:30 -0800
Message-ID: <1194837570.9407.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Fred L. Templin" <fred.l.templin@boeing.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3176 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253AbXKLDTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 22:19:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add inline functions to in.h that make the IP4 address tests
a bit easier to read and also add some type safety.

gcc optimizes IP4_ADDR to a constant (O2 or Os)

Signed-off-by: Joe Perches <joe@perches.com

---

 include/linux/in.h |   75 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 70 insertions(+), 5 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 3975cbf..17d1878 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -247,11 +247,76 @@ struct sockaddr_in {
 
 #ifdef __KERNEL__
 /* Some random defines to make it easier in the kernel.. */
-#define LOOPBACK(x)	(((x) & htonl(0xff000000)) == htonl(0x7f000000))
-#define MULTICAST(x)	(((x) & htonl(0xf0000000)) == htonl(0xe0000000))
-#define BADCLASS(x)	(((x) & htonl(0xf0000000)) == htonl(0xf0000000))
-#define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
-#define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
+
+static inline __be32 IP4_ADDR(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
+{
+	return htonl((((__u32)(a & 0xff)) << 24) |
+		     (((__u32)(b & 0xff)) << 16) |
+		     (((__u32)(c & 0xff)) << 8) |
+		     (((__u32)(d & 0xff)) << 0));
+}
+
+static inline bool LOOPBACK(__be32 x)
+{
+	return (x & IP4_ADDR(255,0,0,0)) == IP4_ADDR(127,0,0,0);
+}
+
+static inline bool MULTICAST(__be32 x)
+{
+	return (x & IP4_ADDR(240,0,0,0)) == IP4_ADDR(224,0,0,0);
+}
+
+static inline bool BADCLASS(__be32 x)
+{
+	return (x & IP4_ADDR(240,0,0,0)) == IP4_ADDR(240,0,0,0);
+}
+
+static inline bool ZERONET(__be32 x)
+{
+	return (x & IP4_ADDR(255,0,0,0)) == IP4_ADDR(0,0,0,0);
+}
+
+static inline bool LOCAL_MCAST(__be32 x)
+{
+	return (x & IP4_ADDR(255,255,255,0)) == IP4_ADDR(224,0,0,0);
+}
+
+/* Special-Use IPv4 Addresses (RFC3330) */
+
+static inline bool PRIVATE_10(__be32 x)
+{
+	return (x & IP4_ADDR(255,0,0,0)) == IP4_ADDR(10,0,0,0);
+}
+
+static inline bool PRIVATE_172(__be32 x)
+{
+	return (x & IP4_ADDR(255,240,0,0)) == IP4_ADDR(172,16,0,0);
+}
+
+static inline bool PRIVATE_192(__be32 x)
+{
+	return (x & IP4_ADDR(255,255,0,0)) == IP4_ADDR(192,168,0,0);
+}
+
+static inline bool TEST_192(__be32 x)
+{
+	return (x & IP4_ADDR(255,255,255,0)) == IP4_ADDR(192,0,2,0);
+}
+
+static inline bool TEST_198(__be32 x)
+{
+	return (x & IP4_ADDR(255,254,0,0)) == IP4_ADDR(198,18,0,0);
+}
+
+static inline bool ANYCAST_6TO4(__be32 x)
+{
+	return (x & IP4_ADDR(255,255,255,0)) == IP4_ADDR(192,88,99,0);
+}
+
+static inline bool LINK_169(__be32 x)
+{
+ 	return (x & IP4_ADDR(255,255,0,0)) == IP4_ADDR(169,254,0,0);
+}
 
 #endif
 


