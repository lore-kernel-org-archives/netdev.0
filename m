From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v1 1/1] pppoe: l2tp: the PPPOX_CONNECTED should be used
 with bit operation
Date: Fri, 19 Aug 2016 06:58:58 +0800
Message-ID: <CA+6hz4oSsVbpNiopMe-CzHyJNwaM-1GzPXMaGKAD5OUuH_EMrA@mail.gmail.com>
References: <1471485543-13149-1-git-send-email-fgao@ikuai8.com> <20160818174402.md35bxj4v35uc2bg@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>, mostrows@earthlink.net,
        jchapman@katalix.com, "David S. Miller" <davem@davemloft.net>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:33611 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753778AbcHSA5M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:57:12 -0400
Received: by mail-ua0-f196.google.com with SMTP id u13so4576557uau.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 17:57:12 -0700 (PDT)
In-Reply-To: <20160818174402.md35bxj4v35uc2bg@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inline.

On Fri, Aug 19, 2016 at 1:44 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Thu, Aug 18, 2016 at 09:59:03AM +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> There are some codes in pppoe and l2tp which use the PPPOX_CONNECTED
>> as the value including assignment and condition check.
>> They should keep consistent with other codes.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v1: Initial Patch
>>
>>  drivers/net/ppp/pppoe.c | 2 +-
>>  net/l2tp/l2tp_ppp.c     | 4 ++--
>>  2 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
>> index 4ddae81..684b773 100644
>> --- a/drivers/net/ppp/pppoe.c
>> +++ b/drivers/net/ppp/pppoe.c
>> @@ -697,7 +697,7 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
>>                       goto err_put;
>>               }
>>
>> -             sk->sk_state = PPPOX_CONNECTED;
>> +             sk->sk_state |= PPPOX_CONNECTED;
>>
> Using plain assignment makes it clear for the reader that other flags
> are unset. I see no reason for changing this.

I get you. So I don't modify the PPPOX_DEAD assignment.
But I am afraid if there is some case that the flag PPPOX_BOUND is set
before PPPOX_CONNECTED . Then the assignment of "PPPOX_CONNECTED" will
clear the PPPOX_BOUND flag.

>
>> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
>> index d9560aa..3984385 100644
>> --- a/net/l2tp/l2tp_ppp.c
>> +++ b/net/l2tp/l2tp_ppp.c
>> @@ -774,7 +774,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
>>  out_no_ppp:
>>       /* This is how we get the session context from the socket. */
>>       sk->sk_user_data = session;
>> -     sk->sk_state = PPPOX_CONNECTED;
>> +     sk->sk_state |= PPPOX_CONNECTED;
>>
> Same here.
>
>> @@ -856,7 +856,7 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
>>       error = -ENOTCONN;
>>       if (sk == NULL)
>>               goto end;
>> -     if (sk->sk_state != PPPOX_CONNECTED)
>> +     if (!(sk->sk_state & PPPOX_CONNECTED))
>>
> Looks like it was a bug. This one is worth a separate patch.

Ok, I send another patch for this bug.

Regards
Feng
