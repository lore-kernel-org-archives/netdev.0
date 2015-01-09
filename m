From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the list
Date: Fri, 9 Jan 2015 10:32:13 +0800
Message-ID: <CA+U0gVgS7z601DZvL82EJfYGYb5XQExw9CbnPRpUeN32TWLF7w@mail.gmail.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <20150108111554.GA8720@gondor.apana.org.au> <CA+U0gVgZr-Mhzest1O_vtCWMwuaQmP30DYb8CLXDG8iTobObYQ@mail.gmail.com>
 <20150109022752.GA15785@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47982 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbAICcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 21:32:35 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so14653347pdb.8
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 18:32:34 -0800 (PST)
In-Reply-To: <20150109022752.GA15785@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 10:27 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Jan 09, 2015 at 10:24:18AM +0800, Dennis Chen wrote:
>>
>> Hi Herbert, please see this code piece in napi_poll:
>>
>>      /* Some drivers may have called napi_schedule
>>      * prior to exhausting their budget.
>>      */
>>     if (unlikely(!list_empty(&n->poll_list))) {
>>         pr_warn_once("%s: Budget exhausted after napi rescheduled\n",
>>                  n->dev ? n->dev->name : "backlog");
>>         goto out_unlock;
>>     }
>>
>> Here "Some drivers" may have called  napi_schedule to make
>> n->poll_list is not empty, does that mean "Some drivers" will clear
>> NAPI_STATE_SCHED bit, otherwise the napi_schedule() will do nothing,
>> does that make sense for you question? ;-)
>
> No it tells me that you don't understand the problem at all.
> Those drivers will end up resetting the NAPI_STATE_SCHED bit
> after clearing it.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Thanks, would you pls give me an example of those drivers? I'll study
it further...

-- 
Den
