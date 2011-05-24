From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: xfrm6: fix dubious code
Date: Tue, 24 May 2011 01:12:12 -0400 (EDT)
Message-ID: <20110524.011212.127532825045335987.davem@davemloft.net>
References: <1306164960.3456.42.camel@localhost>
	<20110523.163302.1123967560115611293.davem@davemloft.net>
	<20110524050242.GD8013@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab1EXFMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 01:12:35 -0400
In-Reply-To: <20110524050242.GD8013@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 24 May 2011 07:02:42 +0200

> I think we can return the value directly like ipv4 does it. xfrm6_rcv_spi()
> returns the return value of xfrm_input() which returns 0 in any case.

Indeed, works for me:

--------------------
ipv6: Fix return of xfrm6_tunnel_rcv()

Like ipv4, just return xfrm6_rcv_spi()'s return value directly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/xfrm6_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index a6770a0..4fe1db1 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -241,7 +241,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 	__be32 spi;
 
 	spi = xfrm6_tunnel_spi_lookup(net, (const xfrm_address_t *)&iph->saddr);
-	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
+	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi);
 }
 
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-- 
1.7.4.4

