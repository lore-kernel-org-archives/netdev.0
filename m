From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv4: check rt_genid in dst_check
Date: Fri, 19 Mar 2010 17:00:22 +0800
Message-ID: <20100319090022.GA23751@gondor.apana.org.au>
References: <1268978083-32070-1-git-send-email-timo.teras@iki.fi> <20100319085600.GA23705@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48057 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752208Ab0CSJA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:00:28 -0400
Content-Disposition: inline
In-Reply-To: <20100319085600.GA23705@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 04:56:00PM +0800, Herbert Xu wrote:
> 
> I'll send a patch to remove the same check on the IPv6 path.

ipv6: Remove redundant dst NULL check in ip6_dst_check

As the only path leading to ip6_dst_check makes an indirect call
through dst->ops, dst cannot be NULL in ip6_dst_check.

This patch removes this check in case it misleads people who
come across this code.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 52cd3ef..7fcb0e5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -879,7 +879,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	rt = (struct rt6_info *) dst;
 
-	if (rt && rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
+	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
 		return dst;
 
 	return NULL;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
