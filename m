From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] net-sched: add packet length pointer parameter for
	qdisc_enqueue
Date: Thu, 31 Jul 2008 17:49:19 +0300
Message-ID: <20080731174919.157875i4bpxod3wg@hayate.ip6>
References: <20080731070233.GA4769@ff.dom.local>
	<20080731120457.34626tsepmygd1c0@hayate.ip6>
	<20080731093612.GB4769@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:33767 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbYGaOtW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 10:49:22 -0400
In-Reply-To: <20080731093612.GB4769@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

> On Thu, Jul 31, 2008 at 12:04:57PM +0300, Jussi Kivilinna wrote:
>> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>>
>>> On 30-07-2008 20:55, Jussi Kivilinna wrote:
>>>> Pass packet length to caller through pointer so that length is
>>>> available to caller even if inner qdisc frees skb.
> ...
>>> As I've written before, IMHO using an skb after enqueuing should be
>>> avoided unless we refcounted it or the returned code is clear enough,
>>> so the idea of this patch could be right to me. But, I guess, you are
>>> changing here the way it's done: the size is calculated before the
>>> current enqueing instead of after the last one.
>>
>> Doh, you're right. qdisc->enqueue should pass packet length too.
>>
>>>
>>> BTW, since I don't really get this "stab" idea enough, I wonder how
>>> it is expected to be used: with a top qdisc, a leaf one or some
>>> summing?
>>>
>>
>> With top and/or leaf qdisc, inner stab overrides upper.
>
> Probably this could be called a bit ugly, but another way could be
> simply updating these .bstas.bytes in ->dequeue() with a difference
> between calculated and skb->len?
>

That would work, but HFSC uses packet length in enqueue for something  
else too:
	if (cl->qdisc->q.qlen == 1)
		set_active(cl, qdisc_pkt_len(skb));

Could this bit be moved to dequeue?

  - Jussi


