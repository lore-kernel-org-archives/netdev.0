From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 8/9] macsec: add missing macsec prefix in uapi
Date: Fri, 22 Apr 2016 11:28:08 +0200
Message-ID: <f8d652f0d117881bebbbcb8010ea41f69b3ca9f8.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754243AbcDVJ2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:44 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I accidentally forgot some MACSEC_ prefixes in if_macsec.h.

Fixes: dece8d2b78d1 ("uapi: add MACsec bits")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c           | 12 +++++++-----
 include/uapi/linux/if_macsec.h |  4 ++--
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index b37d348b8ea0..9f63cc7b0a73 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2232,7 +2232,8 @@ static int nla_put_secy(struct macsec_secy *secy, struct sk_buff *skb)
 		return 1;
 
 	if (nla_put_sci(skb, MACSEC_SECY_ATTR_SCI, secy->sci) ||
-	    nla_put_u64(skb, MACSEC_SECY_ATTR_CIPHER_SUITE, DEFAULT_CIPHER_ID) ||
+	    nla_put_u64(skb, MACSEC_SECY_ATTR_CIPHER_SUITE,
+			MACSEC_DEFAULT_CIPHER_ID) ||
 	    nla_put_u8(skb, MACSEC_SECY_ATTR_ICV_LEN, secy->icv_len) ||
 	    nla_put_u8(skb, MACSEC_SECY_ATTR_OPER, secy->operational) ||
 	    nla_put_u8(skb, MACSEC_SECY_ATTR_PROTECT, secy->protect_frames) ||
@@ -3096,7 +3097,7 @@ unregister:
 
 static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
 {
-	u64 csid = DEFAULT_CIPHER_ID;
+	u64 csid = MACSEC_DEFAULT_CIPHER_ID;
 	u8 icv_len = DEFAULT_ICV_LEN;
 	int flag;
 	bool es, scb, sci;
@@ -3111,8 +3112,8 @@ static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
 		icv_len = nla_get_u8(data[IFLA_MACSEC_ICV_LEN]);
 
 	switch (csid) {
-	case DEFAULT_CIPHER_ID:
-	case DEFAULT_CIPHER_ALT:
+	case MACSEC_DEFAULT_CIPHER_ID:
+	case MACSEC_DEFAULT_CIPHER_ALT:
 		if (icv_len < MACSEC_MIN_ICV_LEN ||
 		    icv_len > MACSEC_MAX_ICV_LEN)
 			return -EINVAL;
@@ -3185,7 +3186,8 @@ static int macsec_fill_info(struct sk_buff *skb,
 
 	if (nla_put_sci(skb, IFLA_MACSEC_SCI, secy->sci) ||
 	    nla_put_u8(skb, IFLA_MACSEC_ICV_LEN, secy->icv_len) ||
-	    nla_put_u64(skb, IFLA_MACSEC_CIPHER_SUITE, DEFAULT_CIPHER_ID) ||
+	    nla_put_u64(skb, IFLA_MACSEC_CIPHER_SUITE,
+			MACSEC_DEFAULT_CIPHER_ID) ||
 	    nla_put_u8(skb, IFLA_MACSEC_ENCODING_SA, tx_sc->encoding_sa) ||
 	    nla_put_u8(skb, IFLA_MACSEC_ENCRYPT, tx_sc->encrypt) ||
 	    nla_put_u8(skb, IFLA_MACSEC_PROTECT, secy->protect_frames) ||
diff --git a/include/uapi/linux/if_macsec.h b/include/uapi/linux/if_macsec.h
index 26b0d1e3e3e7..4c58d9917aa4 100644
--- a/include/uapi/linux/if_macsec.h
+++ b/include/uapi/linux/if_macsec.h
@@ -19,8 +19,8 @@
 
 #define MACSEC_MAX_KEY_LEN 128
 
-#define DEFAULT_CIPHER_ID   0x0080020001000001ULL
-#define DEFAULT_CIPHER_ALT  0x0080C20001000001ULL
+#define MACSEC_DEFAULT_CIPHER_ID   0x0080020001000001ULL
+#define MACSEC_DEFAULT_CIPHER_ALT  0x0080C20001000001ULL
 
 #define MACSEC_MIN_ICV_LEN 8
 #define MACSEC_MAX_ICV_LEN 32
-- 
2.8.0
