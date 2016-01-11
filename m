From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Sun, 10 Jan 2016 21:21:41 -0800
Message-ID: <56933BE5.8090702@gmail.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810> <568F1EE2.7020107@gmail.com> <568FC9F8.8040201@mojatatu.com> <568FD498.5030401@gmail.com> <56926615.6040902@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33566 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcAKFV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 00:21:56 -0500
Received: by mail-pa0-f52.google.com with SMTP id cy9so315643805pac.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 21:21:56 -0800 (PST)
In-Reply-To: <56926615.6040902@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-10 06:09 AM, Jamal Hadi Salim wrote:
> On 16-01-08 10:24 AM, John Fastabend wrote:
>> On 16-01-08 06:38 AM, Jamal Hadi Salim wrote:
>>> On 16-01-07 09:28 PM, John Fastabend wrote:
>>>>
>>>> Hi Jamal,
>>>>
>>>> per your comment about using pktgen to test qdiscs here is the
>>>> patch I've been using most the day which has been working well.
>>>> I'm guessing this is more or less what you had in mind.
>>>>
>>>
>>> I have attached the one i used over the holidays - see if there are
>>> any differences(sorry dont have much time right now).
>>>
>>> cheers,
>>> jamal
>>
>> Close except I don't back off the qdisc when I get
>> xmit_{drop|cn|policed} return codes because I'm trying to
>> stress the qdisc.
>>
> 
> In that case we need two modes. I think it is important to stress
> the qdisc backoff. It doesnt make sense to send packets that will
> be dropped. You said you were testing over vlan - how were you
> enforcing no backoff?

it was aborting so I wasn't able to do this with vlans. It is
interesting for example with pfifo_tail_enqueue where we return
NET_XMIT_CN but still enqueue the packet. If only to test the
qdisc, agreed though "real" users should backoff.

> 
>> Also I don't see the point to doing the skb_get_tx_queue and
>> txq_trans_update() this should be called by dev_queue_xmit
>> anyways.
>>
> 
> Yes, those could go away. They are leftovers of another experiment.
> 
> 
>> If its all the same to you I would just assume have my version in
>> pktgen and later if its useful for you add an option to back-off
>> when the qdisc throws an error.
> 
> 
> Refer to above. If you can fix it so we can do either i will ACK it.

I'll send a Jamal approved version when net-next opens again ;)

Thanks!
John
