From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] xfrm: Remove rebundant address family checking
Date: Tue, 6 Aug 2013 15:50:56 +0800
Message-ID: <1375775456-22628-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41168 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3HFHus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 03:50:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

present_and_same_family has checked addresses family validness for both
SADB_EXT_ADDRESS_SRC and SADB_EXT_ADDRESS_DST in the beginning.
Thereafter pfkey_sadb_addr2xfrm_addr doesn't need to do the checking again.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/key/af_key.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index ab8bd2c..dd40377 100644
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
