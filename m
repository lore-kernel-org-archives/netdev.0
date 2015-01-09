From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the
 list
Date: Fri, 9 Jan 2015 13:27:52 +1100
Message-ID: <20150109022752.GA15785@gondor.apana.org.au>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <20150108111554.GA8720@gondor.apana.org.au>
 <CA+U0gVgZr-Mhzest1O_vtCWMwuaQmP30DYb8CLXDG8iTobObYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Dennis Chen <kernel.org.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42324 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857AbbAIC14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 21:27:56 -0500
Content-Disposition: inline
In-Reply-To: <CA+U0gVgZr-Mhzest1O_vtCWMwuaQmP30DYb8CLXDG8iTobObYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 10:24:18AM +0800, Dennis Chen wrote:
>
> Hi Herbert, please see this code piece in napi_poll:
> 
>      /* Some drivers may have called napi_schedule
>      * prior to exhausting their budget.
>      */
>     if (unlikely(!list_empty(&n->poll_list))) {
>         pr_warn_once("%s: Budget exhausted after napi rescheduled\n",
>                  n->dev ? n->dev->name : "backlog");
>         goto out_unlock;
>     }
> 
> Here "Some drivers" may have called  napi_schedule to make
> n->poll_list is not empty, does that mean "Some drivers" will clear
> NAPI_STATE_SCHED bit, otherwise the napi_schedule() will do nothing,
> does that make sense for you question? ;-)

No it tells me that you don't understand the problem at all.
Those drivers will end up resetting the NAPI_STATE_SCHED bit
after clearing it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
