From: Kyle McMartin <kyle@debian.org>
Subject: [PATCH] IPsec: add support for Twofish and Serpent
Date: Thu, 14 Aug 2003 12:48:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814164819.GA18948@imladris.debian.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


This patch adds support for the use of twofish and serpent as
ESP algorithms. The ESP index numbers given are in accordance
with RFC2407, draft-ietf-ipsec-ciph-aes-cbc-00 (before Rijndael
was selected), and KAME which assigns 253 to twofishcbc.

Support for using twofish was requested on linux-kernel, and
since I noticed serpent was missing too, included that as well.

Regards,
-- 
Kyle McMartin <kyle@debian.org>
1024D/191FCD8A - 331A 9468 C04D 3A76 5C56  BA68 7EB7 92DF 191F CD8A
2048R/F515317D -   68 A9 0D 28 1B DF 8D 42  0F CC AF 98 A8 D5 A4 04

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="pfkeyv2.diff"

--- linux-2.6.0-test3-mm2/include/linux/pfkeyv2.h.old	2003-08-14 10:11:32.000000000 -0400
+++ linux-2.6.0-test3-mm2/include/linux/pfkeyv2.h	2003-08-14 11:30:46.000000000 -0400
@@ -284,7 +284,10 @@
 #define SADB_X_EALG_BLOWFISHCBC		7
 #define SADB_EALG_NULL			11
 #define SADB_X_EALG_AESCBC		12
-#define SADB_EALG_MAX			12
+#define SADB_EALG_MAX                   253 /* last EALG */
+/* private allocations should use 249-255 (RFC2407) */
+#define SADB_X_EALG_SERPENTCBC  252     /* draft-ietf-ipsec-ciph-aes-cbc-00 */
+#define SADB_X_EALG_TWOFISHCBC  253     /* draft-ietf-ipsec-ciph-aes-cbc-00 */
 
 /* Compression algorithms */
 #define SADB_X_CALG_NONE		0

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="xfrm_algo.diff"

--- linux-2.6.0-test3-mm2/net/xfrm/xfrm_algo.c.old	2003-08-14 10:15:04.000000000 -0400
+++ linux-2.6.0-test3-mm2/net/xfrm/xfrm_algo.c	2003-08-14 11:06:20.000000000 -0400
@@ -217,6 +217,40 @@
 		.sadb_alg_maxbits = 256
 	}
 },
+{
+        .name = "serpent",
+
+        .uinfo = {
+                .encr = {
+                        .blockbits = 128,
+                        .defkeybits = 128,
+                }
+        },
+
+        .desc = {
+                .sadb_alg_id = SADB_X_EALG_SERPENTCBC,
+                .sadb_alg_ivlen = 8,
+                .sadb_alg_minbits = 128,
+                .sadb_alg_maxbits = 256,
+        }
+},
+{
+        .name = "twofish",
+                 
+        .uinfo = {
+                .encr = {
+                        .blockbits = 128,
+                        .defkeybits = 128,
+                }
+        },
+
+        .desc = {
+                .sadb_alg_id = SADB_X_EALG_TWOFISHCBC,
+                .sadb_alg_ivlen = 8,
+                .sadb_alg_minbits = 128,
+                .sadb_alg_maxbits = 256
+        }
+},
 };
 
 static struct xfrm_algo_desc calg_list[] = {

--LQksG6bCIzRHxTLp--
