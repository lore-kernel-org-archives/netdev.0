From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net-sched: add packet length pointer parameter for
	qdisc_enqueue
Date: Thu, 31 Jul 2008 09:36:13 +0000
Message-ID: <20080731093612.GB4769@ff.dom.local>
References: <20080731070233.GA4769@ff.dom.local> <20080731120457.34626tsepmygd1c0@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:47370 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbYGaJa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 05:30:56 -0400
Received: by nf-out-0910.google.com with SMTP id d3so188139nfc.21
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 02:30:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080731120457.34626tsepmygd1c0@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 12:04:57PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>
>> On 30-07-2008 20:55, Jussi Kivilinna wrote:
>>> Pass packet length to caller through pointer so that length is
>>> available to caller even if inner qdisc frees skb.
...
>> As I've written before, IMHO using an skb after enqueuing should be
>> avoided unless we refcounted it or the returned code is clear enough,
>> so the idea of this patch could be right to me. But, I guess, you are
>> changing here the way it's done: the size is calculated before the
>> current enqueing instead of after the last one.
>
> Doh, you're right. qdisc->enqueue should pass packet length too.
>
>>
>> BTW, since I don't really get this "stab" idea enough, I wonder how
>> it is expected to be used: with a top qdisc, a leaf one or some
>> summing?
>>
>
> With top and/or leaf qdisc, inner stab overrides upper.

Probably this could be called a bit ugly, but another way could be
simply updating these .bstas.bytes in ->dequeue() with a difference
between calculated and skb->len?

Jarek P.
