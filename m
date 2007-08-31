From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/7] [PPP] pppoe: Fix skb_unshare_check call position
Date: Fri, 31 Aug 2007 17:11:30 +0800
Message-ID: <E1IR2XK-0007Q4-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3591 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754443AbXHaJLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:36 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XL-0004RB-1h
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:31 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XK-0007Q4-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:30 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] pppoe: Fix skb_unshare_check call position

The skb_unshare_check call needs to be made before pskb_may_pull,
not after.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppoe.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 68631a5..5ac3eff 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -385,12 +385,12 @@ static int pppoe_rcv(struct sk_buff *skb,
 	struct pppoe_hdr *ph;
 	struct pppox_sock *po;
 
-	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
-		goto drop;
-
 	if (!(skb = skb_share_check(skb, GFP_ATOMIC)))
 		goto out;
 
+	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
+		goto drop;
+
 	ph = pppoe_hdr(skb);
 
 	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
