From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2 2/6] ipv6: just match on ICMPV6_PKT_TOOBIG in those err_handle
Date: Fri, 13 Sep 2013 10:59:43 +0800
Message-ID: <52327F9F.6080003@cn.fujitsu.com>
References: <52327F00.4040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41364 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab3IMDAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 23:00:39 -0400
In-Reply-To: <52327F00.4040802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

we don't handle NDISC_REDIRECTs here any more, and the match
on ICMPV6_DEST_UNREACH is meaningless.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ah6.c     | 9 ++-------
 net/ipv6/esp6.c    | 9 ++-------
 net/ipv6/ipcomp6.c | 9 ++-------
 3 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 73784c3..79fb40f 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -618,19 +618,14 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG &&
-	    type != NDISC_REDIRECT)
+	if (type != ICMPV6_PKT_TOOBIG)
 		return;
 
 	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
 	if (!x)
 		return;
 
-	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
-	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+	ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
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
