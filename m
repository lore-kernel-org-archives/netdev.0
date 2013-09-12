From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 04/11] ipv6: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:46:49 +0800
Message-ID: <52319B99.6090303@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:47073 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab3ILKrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:47:45 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

So the esp6_err() only handle the ICMPV6_PKT_TOOBIG.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/esp6.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d3618a7..6aa64e1 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -436,9 +436,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG &&
-	    type != NDISC_REDIRECT)
+	if (type != ICMPV6_PKT_TOOBIG)
 		return;
 
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
@@ -446,10 +444,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
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
