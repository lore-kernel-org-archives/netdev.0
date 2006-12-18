From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Mon, 18 Dec 2006 16:56:18 +1100
Message-ID: <20061218055618.GA9386@gondor.apana.org.au>
References: <1164790291.14696.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1894 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753275AbWLRF4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 00:56:30 -0500
To: Li Yewang <lyw@nanjing-fnst.com>
Content-Disposition: inline
In-Reply-To: <1164790291.14696.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 29, 2006 at 04:51:31PM +0800, Li Yewang wrote:
> 
> I have also checked other spots where rate_last/rate_tokens is used.
> Those places need not be fixed.

Thanks.

> Following is my patch:
> 
> signed-off-by: Li Yewang<lyw@nanjing-fnst.com>

Looks good to me.  You should cc David Miller <davem@davemloft.net>
for patch submissions.  Please also include a full description each
time you submit the patch.

> --- linux-2.6.19.1/net/ipv4/route.c     2006-12-12 03:32:54.000000000
> +0800
> +++ linux-2.6.19.1/net/ipv4/route.org.c 2006-11-29 16:14:34.592058480
> +0800
> @@ -1327,7 +1327,8 @@ void ip_rt_send_redirect(struct sk_buff
>         /* Check for load limit; set rate_last to the latest sent
>          * redirect.
>          */
> -       if (time_after(jiffies,
> +       if (rt->u.dst.rate_tokens == 0 ||
> +            time_after(jiffies,
>                        (rt->u.dst.rate_last +
>                         (ip_rt_redirect_load << rt-
> >u.dst.rate_tokens)))) {
>                 icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt-
> >rt_gateway);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
