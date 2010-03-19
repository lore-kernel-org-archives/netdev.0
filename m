From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv4: check rt_genid in dst_check
Date: Fri, 19 Mar 2010 16:56:00 +0800
Message-ID: <20100319085600.GA23705@gondor.apana.org.au>
References: <1268978083-32070-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37134 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751329Ab0CSI4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 04:56:02 -0400
Content-Disposition: inline
In-Reply-To: <1268978083-32070-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> wrote:
>
> @@ -1726,7 +1726,9 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
> 
> static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
> {
> -       return NULL;
> +       if (dst && rt_is_expired((struct rtable *)dst))
> +               return NULL;

Sorry I didn't spot this the first time around, but the dst check
is redundant too.  Since the only path leading to this code is

static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
{
	if (dst->obsolete)
		dst = dst->ops->check(dst, cookie);
	return dst;
}

I'll send a patch to remove the same check on the IPv6 path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
