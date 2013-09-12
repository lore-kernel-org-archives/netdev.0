From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 07/11] ipv6: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:49:59 +0800
Message-ID: <52319C57.5030402@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:4031 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751780Ab3ILKux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:50:53 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

So the ipcomm6_err() only handle the ICMPV6_PKT_TOOBIG.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ipcomp6.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 5636a91..e943158 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -64,9 +64,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		(struct ip_comp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG &&
-	    type != NDISC_REDIRECT)
+	if (type != ICMPV6_PKT_TOOBIG)
 		return;
 
 	spi = htonl(ntohs(ipcomph->cpi));
@@ -75,10 +73,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
-	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+	ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
-- 
1.8.3.1
