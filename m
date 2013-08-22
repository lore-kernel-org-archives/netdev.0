From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH ipsec 1/2] xfrm: revert ipv4 mtu determination to dst_mtu
Date: Thu, 22 Aug 2013 21:53:56 +0200
Message-ID: <20130822195355.GA4784@order.stressinduktion.org>
References: <20130822104724.GD26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40499 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab3HVTx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:53:57 -0400
Content-Disposition: inline
In-Reply-To: <20130822104724.GD26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 0ea9d5e3e0e03a63b11392f5613378977dae7eca ("xfrm: introduce
helper for safe determination of mtu") I switched the determination of
ipv4 mtus from dst_mtu to ip_skb_dst_mtu. This was an error because in
case of IP_PMTUDISC_PROBE we fall back to the interface mtu, which is
never correct for ipv4 ipsec.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/xfrm.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac5b025..65d3529 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1730,8 +1730,6 @@ static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
 
 	if (sk && skb->protocol == htons(ETH_P_IPV6))
 		return ip6_skb_dst_mtu(skb);
-	else if (sk && skb->protocol == htons(ETH_P_IP))
-		return ip_skb_dst_mtu(skb);
 	return dst_mtu(skb_dst(skb));
 }
 
-- 
1.8.3.1
