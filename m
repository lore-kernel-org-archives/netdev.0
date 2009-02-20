From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3] gre: used time_before for comparing jiffies
Date: Fri, 20 Feb 2009 16:39:35 +0800
Message-ID: <20090220083935.GA18673@gondor.apana.org.au>
References: <20090220.000133.175557384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53305 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756564AbZBTIjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:39:43 -0500
Content-Disposition: inline
In-Reply-To: <20090220.000133.175557384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> There is some history of this in the networking code.
> 
> If you inspect carefully, the open-coded versions of
> time comparisons in the networking have a larger window
> of acceptance.

Hmm, it looks like the macro version is actually better in this
case.

-	if (jiffies - t->err_time < IPTUNNEL_ERR_TIMEO)

This wraps at jiffies = LONG_MAX + t->err_time + 1

+	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))

This expands to

	(long)jiffies - (long)(t->err_time + IPTUNNEL_ERR_TIMEO) < 0

which wraps at jiffies = LONG_MAX + t->err_time + IPTUNNEL_ERR_TIMEO + 1

So assuming that IPTUNNEL_ERR_TIMEO > 0, then the macro version
wraps around after the open-coded version, which would seem to
mean that it's better, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
