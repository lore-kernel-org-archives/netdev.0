From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Fri, 08 Jan 2016 16:41:30 -0800
Message-ID: <5690573A.6090305@gmail.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810> <568F1EE2.7020107@gmail.com> <568FC9F8.8040201@mojatatu.com> <568FD498.5030401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33944 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbcAIAll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 19:41:41 -0500
Received: by mail-pa0-f43.google.com with SMTP id uo6so272464291pac.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 16:41:41 -0800 (PST)
In-Reply-To: <568FD498.5030401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-08 07:24 AM, John Fastabend wrote:
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
> Also I don't see the point to doing the skb_get_tx_queue and
> txq_trans_update() this should be called by dev_queue_xmit
> anyways.
> 
> If its all the same to you I would just assume have my version in
> pktgen and later if its useful for you add an option to back-off
> when the qdisc throws an error.
> 
> Thanks,
> John
> 
> 

And burst > 1 will cause a panic as well when injecting the packet
into dev_queue_xmit(). It seems skb->users > 1 which is what the
burst value is tuning in pktgen will stop the skb from being free'd
but the stack doesn't check skb_shared().

.John
