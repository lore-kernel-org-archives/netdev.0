From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 82/84] ipvs: Remove skb_net
Date: Thu, 24 Sep 2015 09:53:07 +0900
Message-ID: <1443055989-1306-83-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44941 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012AbbIXAzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 20:55:52 -0400
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This hack has no more users so remove it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 00318d63a565..d621330d423c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -38,37 +38,6 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
 	return net->ipvs;
 }
 
-/* Get net ptr from skb in traffic cases
- * use skb_sknet when call is from userland (ioctl or netlink)
- */
-static inline struct net *skb_net(const struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-#ifdef CONFIG_IP_VS_DEBUG
-	/*
-	 * This is used for debug only.
-	 * Start with the most likely hit
-	 * End with BUG
-	 */
-	if (likely(skb->dev && dev_net(skb->dev)))
-		return dev_net(skb->dev);
-	if (skb_dst(skb) && skb_dst(skb)->dev)
-		return dev_net(skb_dst(skb)->dev);
-	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
-		      __func__, __LINE__);
-	if (likely(skb->sk && sock_net(skb->sk)))
-		return sock_net(skb->sk);
-	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
-		__func__, __LINE__);
-	BUG();
-#else
-	return dev_net(skb->dev ? : skb_dst(skb)->dev);
-#endif
-#else
-	return &init_net;
-#endif
-}
-
 static inline struct net *skb_sknet(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_NS
-- 
2.1.4
