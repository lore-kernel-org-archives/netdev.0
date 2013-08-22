From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/6] xfrm: Remove rebundant address family checking
Date: Thu, 22 Aug 2013 13:12:08 +0200
Message-ID: <1377169931-7302-5-git-send-email-steffen.klassert@secunet.com>
References: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51119 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab3HVLMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:12:36 -0400
In-Reply-To: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

present_and_same_family has checked addresses family validness for both
SADB_EXT_ADDRESS_SRC and SADB_EXT_ADDRESS_DST in the beginning.
Thereafter pfkey_sadb_addr2xfrm_addr doesn't need to do the checking again.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index d49f676..9d58537 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1196,10 +1196,6 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 
 	x->props.family = pfkey_sadb_addr2xfrm_addr((struct sadb_address *) ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 						    &x->props.saddr);
-	if (!x->props.family) {
-		err = -EAFNOSUPPORT;
-		goto out;
-	}
 	pfkey_sadb_addr2xfrm_addr((struct sadb_address *) ext_hdrs[SADB_EXT_ADDRESS_DST-1],
 				  &x->id.daddr);
 
@@ -2205,10 +2201,6 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_SRC-1];
 	xp->family = pfkey_sadb_addr2xfrm_addr(sa, &xp->selector.saddr);
-	if (!xp->family) {
-		err = -EINVAL;
-		goto out;
-	}
 	xp->selector.family = xp->family;
 	xp->selector.prefixlen_s = sa->sadb_address_prefixlen;
 	xp->selector.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
-- 
1.7.9.5
