From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the list
Date: Fri, 9 Jan 2015 10:24:18 +0800
Message-ID: <CA+U0gVgZr-Mhzest1O_vtCWMwuaQmP30DYb8CLXDG8iTobObYQ@mail.gmail.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <20150108111554.GA8720@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:52611 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbbAICYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 21:24:39 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so14582604pde.12
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 18:24:39 -0800 (PST)
In-Reply-To: <20150108111554.GA8720@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 7:15 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Dennis Chen <kernel.org.gnu@gmail.com> wrote:
>> Some drivers may clear the NAPI_STATE_SCHED bit upon the state of the
>> NAPI instance after exhaust the budget in the poll function, which
>> will open a window for next device interrupt handler to insert a same
>> instance to the list after calling list_add_tail(&n->poll_list,
>> repoll) if we don't set this bit.
>>
>> Signed-off-by: Dennis Chen <kernel.org.gnu@gmail.com>
>
> Which driver is doing this?
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Hi Herbert, please see this code piece in napi_poll:

     /* Some drivers may have called napi_schedule
     * prior to exhausting their budget.
     */
    if (unlikely(!list_empty(&n->poll_list))) {
        pr_warn_once("%s: Budget exhausted after napi rescheduled\n",
                 n->dev ? n->dev->name : "backlog");
        goto out_unlock;
    }

Here "Some drivers" may have called  napi_schedule to make
n->poll_list is not empty, does that mean "Some drivers" will clear
NAPI_STATE_SCHED bit, otherwise the napi_schedule() will do nothing,
does that make sense for you question? ;-)

-- 
Den
