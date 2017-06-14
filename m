From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 05/11] key: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:47:55 +0800
Message-ID: <1497451675-4548-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:37589 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751065AbdFNOsW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:48:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/key/af_key.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 512dc43..c6c7cbf 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2934,8 +2934,7 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 
 		if (aalg_tmpl_set(t, aalg) && aalg->available) {
 			struct sadb_comb *c;
-			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
-			memset(c, 0, sizeof(*c));
+			c = (struct sadb_comb*)skb_put_zero(skb, sizeof(struct sadb_comb));
 			p->sadb_prop_len += sizeof(struct sadb_comb)/8;
 			c->sadb_comb_auth = aalg->desc.sadb_alg_id;
 			c->sadb_comb_auth_minbits = aalg->desc.sadb_alg_minbits;
@@ -2979,8 +2978,7 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 				continue;
 			if (!(aalg_tmpl_set(t, aalg) && aalg->available))
 				continue;
-			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
-			memset(c, 0, sizeof(*c));
+			c = (struct sadb_comb*)skb_put_zero(skb, sizeof(struct sadb_comb));
 			p->sadb_prop_len += sizeof(struct sadb_comb)/8;
 			c->sadb_comb_auth = aalg->desc.sadb_alg_id;
 			c->sadb_comb_auth_minbits = aalg->desc.sadb_alg_minbits;
@@ -3461,8 +3459,7 @@ static int set_sadb_kmaddress(struct sk_buff *skb, const struct xfrm_kmaddress *
 	size_req = (sizeof(struct sadb_x_kmaddress) +
 		    pfkey_sockaddr_pair_size(family));
 
-	kma = (struct sadb_x_kmaddress *)skb_put(skb, size_req);
-	memset(kma, 0, size_req);
+	kma = (struct sadb_x_kmaddress *)skb_put_zero(skb, size_req);
 	kma->sadb_x_kmaddress_len = size_req / 8;
 	kma->sadb_x_kmaddress_exttype = SADB_X_EXT_KMADDRESS;
 	kma->sadb_x_kmaddress_reserved = k->reserved;
@@ -3488,8 +3485,7 @@ static int set_ipsecrequest(struct sk_buff *skb,
 	size_req = sizeof(struct sadb_x_ipsecrequest) +
 		   pfkey_sockaddr_pair_size(family);
 
-	rq = (struct sadb_x_ipsecrequest *)skb_put(skb, size_req);
-	memset(rq, 0, size_req);
+	rq = (struct sadb_x_ipsecrequest *)skb_put_zero(skb, size_req);
 	rq->sadb_x_ipsecrequest_len = size_req;
 	rq->sadb_x_ipsecrequest_proto = proto;
 	rq->sadb_x_ipsecrequest_mode = mode;
-- 
2.7.4
