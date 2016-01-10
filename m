From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Sun, 10 Jan 2016 09:09:25 -0500
Message-ID: <56926615.6040902@mojatatu.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810>
 <568F1EE2.7020107@gmail.com> <568FC9F8.8040201@mojatatu.com>
 <568FD498.5030401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37252 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757160AbcAJOJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 09:09:33 -0500
Received: by mail-ig0-f175.google.com with SMTP id h5so58337311igh.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 06:09:32 -0800 (PST)
In-Reply-To: <568FD498.5030401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-08 10:24 AM, John Fastabend wrote:
> On 16-01-08 06:38 AM, Jamal Hadi Salim wrote:
>> On 16-01-07 09:28 PM, John Fastabend wrote:
>>>
>>> Hi Jamal,
>>>
>>> per your comment about using pktgen to test qdiscs here is the
>>> patch I've been using most the day which has been working well.
>>> I'm guessing this is more or less what you had in mind.
>>>
>>
>> I have attached the one i used over the holidays - see if there are
>> any differences(sorry dont have much time right now).
>>
>> cheers,
>> jamal
>
> Close except I don't back off the qdisc when I get
> xmit_{drop|cn|policed} return codes because I'm trying to
> stress the qdisc.
>

In that case we need two modes. I think it is important to stress
the qdisc backoff. It doesnt make sense to send packets that will
be dropped. You said you were testing over vlan - how were you
enforcing no backoff?

> Also I don't see the point to doing the skb_get_tx_queue and
> txq_trans_update() this should be called by dev_queue_xmit
> anyways.
>

Yes, those could go away. They are leftovers of another experiment.


> If its all the same to you I would just assume have my version in
> pktgen and later if its useful for you add an option to back-off
> when the qdisc throws an error.


Refer to above. If you can fix it so we can do either i will ACK it.

cheers,
jamal
