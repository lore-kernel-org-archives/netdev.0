From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ceph: armor.c:  Remove unused function
Date: Sat, 20 Dec 2014 23:36:40 +0100
Message-ID: <1419115000-12178-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <ceph-devel-owner@vger.kernel.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function ceph_armor() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 net/ceph/armor.c  |   39 ---------------------------------------
 net/ceph/crypto.h |    1 -
 2 files changed, 40 deletions(-)

diff --git a/net/ceph/armor.c b/net/ceph/armor.c
index 1fc1ee1..05e0d2b 100644
--- a/net/ceph/armor.c
+++ b/net/ceph/armor.c
@@ -1,7 +1,6 @@
 
 #include <linux/errno.h>
 
-int ceph_armor(char *dst, const char *src, const char *end);
 int ceph_unarmor(char *dst, const char *src, const char *end);
 
 /*
@@ -33,44 +32,6 @@ static int decode_bits(char c)
 	return -EINVAL;
 }
 
-int ceph_armor(char *dst, const char *src, const char *end)
-{
-	int olen = 0;
-	int line = 0;
-
-	while (src < end) {
-		unsigned char a, b, c;
-
-		a = *src++;
-		*dst++ = encode_bits(a >> 2);
-		if (src < end) {
-			b = *src++;
-			*dst++ = encode_bits(((a & 3) << 4) | (b >> 4));
-			if (src < end) {
-				c = *src++;
-				*dst++ = encode_bits(((b & 15) << 2) |
-						     (c >> 6));
-				*dst++ = encode_bits(c & 63);
-			} else {
-				*dst++ = encode_bits((b & 15) << 2);
-				*dst++ = '=';
-			}
-		} else {
-			*dst++ = encode_bits(((a & 3) << 4));
-			*dst++ = '=';
-			*dst++ = '=';
-		}
-		olen += 4;
-		line += 4;
-		if (line == 64) {
-			line = 0;
-			*(dst++) = '\n';
-			olen++;
-		}
-	}
-	return olen;
-}
-
 int ceph_unarmor(char *dst, const char *src, const char *end)
 {
 	int olen = 0;
diff --git a/net/ceph/crypto.h b/net/ceph/crypto.h
index d149822..5cbc7b1 100644
--- a/net/ceph/crypto.h
+++ b/net/ceph/crypto.h
@@ -45,7 +45,6 @@ int ceph_crypto_init(void);
 void ceph_crypto_shutdown(void);
 
 /* armor.c */
-int ceph_armor(char *dst, const char *src, const char *end);
 int ceph_unarmor(char *dst, const char *src, const char *end);
 
 #endif
-- 
1.7.10.4

