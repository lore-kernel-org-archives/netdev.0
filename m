From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the list
Date: Fri, 9 Jan 2015 10:28:51 +0800
Message-ID: <CA+U0gVizSTd0ynJUQD7FwrpeTJyc8RttauT_eZk=xuOfuBgtvw@mail.gmail.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <54AE8048.6040105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48149 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbbAIC3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 21:29:12 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so15514929pab.5
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 18:29:11 -0800 (PST)
In-Reply-To: <54AE8048.6040105@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello,

On Thu, Jan 8, 2015 at 9:04 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 1/8/2015 11:22 AM, Dennis Chen wrote:
>
>> Some drivers may clear the NAPI_STATE_SCHED bit upon the state of the
>> NAPI instance after exhaust the budget in the poll function, which
>> will open a window for next device interrupt handler to insert a same
>> instance to the list after calling list_add_tail(&n->poll_list,
>> repoll) if we don't set this bit.
>
>
>> Signed-off-by: Dennis Chen <kernel.org.gnu@gmail.com>
>> ---
>>   net/core/dev.c |    8 ++++++++
>>   1 file changed, 8 insertions(+)
>
>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 683d493..b3107ac 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4619,6 +4619,14 @@ static int napi_poll(struct napi_struct *n,
>> struct list_head *repoll)
>>                               n->dev ? n->dev->name : "backlog");
>>                  goto out_unlock;
>>          }
>> +
>> +       /* Some drivers may exit the polling mode when exhaust the
>
>
>    s/exhaust/exhausting/.
>
>> +        * budget. Set the NAPI_STATE_SCHED bit to prevent multiple NAPI
>> +        * instances in the list in case of next device interrupt raised.
>> +        */
>> +       if (unlikely(!test_and_set_bit(NAPI_STATE_SCHED, &n->state)))
>> +               pr_warn_once("%s: exit polling mode after exhaust the
>> budget\n",
>
>
>    Likewise. And s/exit/exiting/.
>
> WBR, Sergei
>

will be updated if applied :-)

-- 
Den
