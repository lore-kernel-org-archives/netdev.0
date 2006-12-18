From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Mon, 18 Dec 2006 14:02:43 +1100
Message-ID: <20061218030243.GB7902@gondor.apana.org.au>
References: <1164787726.14560.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1093 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752139AbWLRDCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 22:02:52 -0500
To: Li Yewang <lyw@nanjing-fnst.com>
Content-Disposition: inline
In-Reply-To: <1164787726.14560.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 29, 2006 at 04:08:45PM +0800, Li Yewang wrote:
> 
> --- linux-2.6.19/net/ipv4/route.c.org 2006-12-05 10:47:02.402147160
> +0800
> +++ linux-2.6.19/net/ipv4/route.c 2006-12-05 10:48:26.339386760 +0800
> @@ -1327,7 +1327,8 @@ void ip_rt_send_redirect(struct sk_buff 
>   /* Check for load limit; set rate_last to the latest sent
>    * redirect.
>    */
> - if (time_after(jiffies,
> + if (rt->u.dst.rate_last == 0 ||
> +     time_after(jiffies,
>           (rt->u.dst.rate_last +
>     (ip_rt_redirect_load << rt->u.dst.rate_tokens)))) {
>    icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);

Since rate_last can also be zero if jiffies == 0 (OK that's
extremely unlikely but I'm feeling picky today :), how about
checking rate_tokens instead? The value of rate_last can only
be relevant if rate_tokens is non-zero.

BTW, please also check the other spots where rate_last/rate_token
is used.  They might need a similar fix.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
