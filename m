From: Olivier MATZ <olivier.matz@6wind.com>
Subject: Re: [PATCH] sctp: chunkmap size is too large
Date: Mon, 02 Feb 2009 10:23:24 +0100
Message-ID: <4986BB8C.5080503@6wind.com>
References: <4983200B.2080707@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060500040804020500040107"
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4983200B.2080707@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060500040804020500040107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

A file was missing in the previous patch. I think that
the size of chunkmapcopy in xt_sctp.c should also be
fixed.

I attached the new patch.

  include/linux/netfilter/xt_sctp.h       |   30 
++++++++++++++++--------------
  include/linux/netfilter_ipv4/ipt_sctp.h |   30 
++++++++++++++++--------------
  net/netfilter/xt_sctp.c                 |    2 +-
  3 files changed, 33 insertions(+), 29 deletions(-)

Signed-off-by: Olivier Matz <olivier.matz@6wind.com>

Thanks,
Olivier


--------------060500040804020500040107
Content-Type: text/x-patch;
 name="linux_sctp_chunkmap_too_large_b.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux_sctp_chunkmap_too_large_b.diff"

diff -r 94166a3a38bd include/linux/netfilter/xt_sctp.h
--- a/include/linux/netfilter/xt_sctp.h	Sat Jan 31 15:56:23 2009 -0800
+++ b/include/linux/netfilter/xt_sctp.h	Mon Feb 02 10:18:51 2009 +0100
@@ -15,11 +15,13 @@
 
 #define XT_NUM_SCTP_FLAGS	4
 
+#define sizeof_bits(type) (sizeof(type) * 8)
+
 struct xt_sctp_info {
 	u_int16_t dpts[2];  /* Min, Max */
 	u_int16_t spts[2];  /* Min, Max */
 
-	u_int32_t chunkmap[256 / sizeof (u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
+	u_int32_t chunkmap[256 / sizeof_bits(u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
 
 #define SCTP_CHUNK_MATCH_ANY   0x01  /* Match if any of the chunk types are present */
 #define SCTP_CHUNK_MATCH_ALL   0x02  /* Match if all of the chunk types are present */
@@ -33,24 +35,24 @@
 	u_int32_t invflags;
 };
 
-#define bytes(type) (sizeof(type) * 8)
+#define SCTP_MODULO(chunktype, type) (chunktype & (sizeof_bits(type)-1))
 
-#define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
-	do { 						\
-		(chunkmap)[type / bytes(u_int32_t)] |= 	\
-			1 << (type % bytes(u_int32_t));	\
+#define SCTP_CHUNKMAP_SET(chunkmap, chunktype)				\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] |=		\
+			1 << SCTP_MODULO(chunktype, u_int32_t);		\
 	} while (0)
 
-#define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
-	do {							\
-		(chunkmap)[type / bytes(u_int32_t)] &= 		\
-			~(1 << (type % bytes(u_int32_t)));	\
+#define SCTP_CHUNKMAP_CLEAR(chunkmap, chunktype)		 	\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] &=		\
+			~(1 << SCTP_MODULO(chunktype, u_int32_t));	\
 	} while (0)
 
-#define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
-({								\
-	((chunkmap)[type / bytes (u_int32_t)] & 		\
-		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
+#define SCTP_CHUNKMAP_IS_SET(chunkmap, chunktype) 			\
+({									\
+	(chunkmap[chunktype / sizeof_bits(u_int32_t)] &			\
+	 (1 << SCTP_MODULO(chunktype, u_int32_t))) ? 1 : 0;		\
 })
 
 #define SCTP_CHUNKMAP_RESET(chunkmap) \
diff -r 94166a3a38bd include/linux/netfilter_ipv4/ipt_sctp.h
--- a/include/linux/netfilter_ipv4/ipt_sctp.h	Sat Jan 31 15:56:23 2009 -0800
+++ b/include/linux/netfilter_ipv4/ipt_sctp.h	Mon Feb 02 10:18:51 2009 +0100
@@ -16,11 +16,13 @@
 
 #define IPT_NUM_SCTP_FLAGS	4
 
+#define sizeof_bits(type) (sizeof(type) * 8)
+
 struct ipt_sctp_info {
 	u_int16_t dpts[2];  /* Min, Max */
 	u_int16_t spts[2];  /* Min, Max */
 
-	u_int32_t chunkmap[256 / sizeof (u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
+	u_int32_t chunkmap[256 / sizeof_bits(u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
 
 #define SCTP_CHUNK_MATCH_ANY   0x01  /* Match if any of the chunk types are present */
 #define SCTP_CHUNK_MATCH_ALL   0x02  /* Match if all of the chunk types are present */
@@ -34,24 +36,24 @@
 	u_int32_t invflags;
 };
 
-#define bytes(type) (sizeof(type) * 8)
+#define SCTP_MODULO(chunktype, type) (chunktype & (sizeof_bits(type)-1))
 
-#define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
-	do { 						\
-		chunkmap[type / bytes(u_int32_t)] |= 	\
-			1 << (type % bytes(u_int32_t));	\
+#define SCTP_CHUNKMAP_SET(chunkmap, chunktype)				\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] |=		\
+			1 << SCTP_MODULO(chunktype, u_int32_t);		\
 	} while (0)
 
-#define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
-	do {							\
-		chunkmap[type / bytes(u_int32_t)] &= 		\
-			~(1 << (type % bytes(u_int32_t)));	\
+#define SCTP_CHUNKMAP_CLEAR(chunkmap, chunktype)		 	\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] &=		\
+			~(1 << SCTP_MODULO(chunktype, u_int32_t));	\
 	} while (0)
 
-#define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
-({								\
-	(chunkmap[type / bytes (u_int32_t)] & 			\
-		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
+#define SCTP_CHUNKMAP_IS_SET(chunkmap, chunktype) 			\
+({									\
+	(chunkmap[chunktype / sizeof_bits(u_int32_t)] &			\
+	 (1 << SCTP_MODULO(chunktype, u_int32_t))) ? 1 : 0;		\
 })
 
 #define SCTP_CHUNKMAP_RESET(chunkmap) 				\
diff -r 94166a3a38bd net/netfilter/xt_sctp.c
--- a/net/netfilter/xt_sctp.c	Sat Jan 31 15:56:23 2009 -0800
+++ b/net/netfilter/xt_sctp.c	Mon Feb 02 10:18:51 2009 +0100
@@ -45,7 +45,7 @@
 	     const struct xt_sctp_info *info,
 	     bool *hotdrop)
 {
-	u_int32_t chunkmapcopy[256 / sizeof (u_int32_t)];
+	u_int32_t chunkmapcopy[256 / sizeof_bits(u_int32_t)];
 	const sctp_chunkhdr_t *sch;
 	sctp_chunkhdr_t _sch;
 	int chunk_match_type = info->chunk_match_type;

--------------060500040804020500040107--
