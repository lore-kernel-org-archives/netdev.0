From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 3/3] net_sched: Add size table for qdiscs
Date: Mon, 21 Jul 2008 15:00:33 +0200
Message-ID: <48848871.3050900@trash.net>
References: <20080717100921.3327.3324.stgit@fate.lan>	<20080717100938.3327.45121.stgit@fate.lan> <487F1F58.3040701@trash.net> <20080717210231.28364m21mg503g8w@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36952 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbYGUNAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 09:00:36 -0400
In-Reply-To: <20080717210231.28364m21mg503g8w@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Quoting "Patrick McHardy" <kaber@trash.net>:
> 
>>> @@ -123,9 +123,9 @@ static int tbf_enqueue(struct sk_buff *skb,  
>>> struct Qdisc* sch)
>>>     struct tbf_sched_data *q = qdisc_priv(sch);
>>>     int ret;
>>> -    /* qdisc_tx_len() before qdisc_enqueue() wrapper, might return 
>>> different
>>> -     * length than after wrapper. Should recalculate tx_len here if 
>>> q->qdisc
>>> -     * has size table? */
>>> +    if (q->qdisc->stab)
>>> +        qdisc_calculate_tx_len(skb, q->qdisc->stab);
>>> +
>>
>> I don't think this will help, the inner qdisc might again have
>> an inner qdisc that increases the size. So this probably needs
>> to be handled during dequeue.
>>
> 
> I don't quite follow you here, what needs to be handled during dequeue? 
> tbf's q->max_size check?


Yes. You check on ->enqueue by using the inner qdiscs size table,
but that qdisc might again have an inner qdisc which increases
the size, which you can't check during ->enqueue.
