From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 1/1] tcp: fixing TLP's FIN recovery
Date: Thu, 12 Jun 2014 13:46:50 -0400
Message-ID: <CADVnQymKHsd4HD-vJgTEhf2L_5Trae-Peo4Z4be2k5MhenC6+g@mail.gmail.com>
References: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402585712-12103-1-git-send-email-per.hurtig@kau.se>
	<1402586916.3645.485.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAB_+Fg69Ub-AQn3FyvcGTq7PQK9Lxi=zF8xPW+f4Qjhr6oJ+JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Per Hurtig <per.hurtig@kau.se>, panweiping3@gmail.com,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, sergei.shtylyov@cogentembedded.com
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:49720 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaFLRqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 13:46:51 -0400
Received: by mail-we0-f171.google.com with SMTP id q58so1675581wes.30
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 10:46:50 -0700 (PDT)
In-Reply-To: <CAB_+Fg69Ub-AQn3FyvcGTq7PQK9Lxi=zF8xPW+f4Qjhr6oJ+JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2014 at 1:36 PM, Nandita Dukkipati <nanditad@google.com> wrote:
> On Thu, Jun 12, 2014 at 8:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2014-06-12 at 17:08 +0200, Per Hurtig wrote:
>>> Fix to a problem observed when losing a FIN segment that does not
>>> contain data.  In such situations, TLP is unable to recover from
>>> *any* tail loss and instead adds at least PTO ms to the
>>> retransmission process, i.e., RTO = RTO + PTO.
>>>
>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>> ---
>>>  net/ipv4/tcp_output.c | 4 +---
>>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>>
>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>> index ad7549f..819bf0c 100644
>>> --- a/net/ipv4/tcp_output.c
>>> +++ b/net/ipv4/tcp_output.c
>>> @@ -2131,9 +2131,7 @@ void tcp_send_loss_probe(struct sock *sk)
>>>       if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>>>               goto rearm_timer;
>>>
>>> -     /* Probe with zero data doesn't trigger fast recovery. */
>>> -     if (skb->len > 0)
>>> -             err = __tcp_retransmit_skb(sk, skb);
>>> +     err = __tcp_retransmit_skb(sk, skb);
>>>
>>>       /* Record snd_nxt for loss detection. */
>>>       if (likely(!err))
>>
>> Thanks a lot Per
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Acked-by: Nandita Dukkipati <nanditad@google.com>

Thanks, Per!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
