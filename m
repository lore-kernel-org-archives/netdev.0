From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the list
Date: Fri, 9 Jan 2015 10:26:48 +0800
Message-ID: <CA+U0gVi1cVB4qbXAkPp1LMmNOaDOD2UaAL4riA6O_Q_SnvMQTA@mail.gmail.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <1420728671.5947.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52469 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbbAIC1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 21:27:10 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so15538930pad.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 18:27:09 -0800 (PST)
In-Reply-To: <1420728671.5947.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am very curious about the reason that you're removing the atomic ops
in the stack, what's the benifit?

On Thu, Jan 8, 2015 at 10:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-01-08 at 16:22 +0800, Dennis Chen wrote:
>> Some drivers may clear the NAPI_STATE_SCHED bit upon the state of the
>> NAPI instance after exhaust the budget in the poll function, which
>> will open a window for next device interrupt handler to insert a same
>> instance to the list after calling list_add_tail(&n->poll_list,
>> repoll) if we don't set this bit.
>>
>> Signed-off-by: Dennis Chen <kernel.org.gnu@gmail.com>
>> ---
>
>
> Well no.
>
> I am removing some atomic ops in the stack, please do not add new ones,
> especially if no driver is that buggy.
>
> The unlikely() wont help the expensive stuff being done here.
>
>



-- 
Den
