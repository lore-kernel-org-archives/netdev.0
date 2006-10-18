From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 4/4] add the algorithm to IPsec
Date: Wed, 18 Oct 2006 11:26:23 +0900
Message-ID: <20061018112623.29ed9324.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:58859 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1751185AbWJRC0Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 22:26:25 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The glue of xfrm.

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
---
 include/linux/pfkeyv2.h |    1 +
 net/xfrm/xfrm_algo.c    |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index d5dd471..636e0fb 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -285,6 +285,7 @@ #define SADB_X_AALG_SHA2_256HMAC	5
 #define SADB_X_AALG_SHA2_384HMAC	6
 #define SADB_X_AALG_SHA2_512HMAC	7
 #define SADB_X_AALG_RIPEMD160HMAC	8
+#define SADB_X_AALG_AES_XCBC_MAC	9
 #define SADB_X_AALG_NULL		251	/* kame */
 #define SADB_AALG_MAX			251
 
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 5a0dbeb..e03eadd 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -119,6 +119,24 @@ static struct xfrm_algo_desc aalg_list[]
 		.sadb_alg_maxbits = 160
 	}
 },
+{
+	.name = "xcbc(aes)",
+	.compat = "aes_xcbc_128",
+
+	.uinfo = {
+		.auth = {
+			.icv_truncbits = 96,
+			.icv_fullbits = 128,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_AALG_AES_XCBC_MAC,
+		.sadb_alg_ivlen = 0,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 128
+	}
+},
 };
 
 static struct xfrm_algo_desc ealg_list[] = {
-- 
1.4.2
