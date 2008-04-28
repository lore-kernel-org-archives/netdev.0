From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Mon, 28 Apr 2008 16:02:01 +0200
Message-ID: <4815D8D9.5020201@trash.net>
References: <20080427142216.GB7480@ami.dom.local> <4814C618.3050506@trash.net> <20080427203630.GA9648@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55821 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765697AbYD1OB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:01:59 -0400
In-Reply-To: <20080427203630.GA9648@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Sun, Apr 27, 2008 at 08:29:44PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
>>>
>> Besides this *will* break for example my configuration, I use SFQ
>> as inner qdisc on virtual devices with either tx_queue_len == 0
>> or 3 in case of ppp.
> 
> OK, you are right: it would break some scripts... But IMHO this way
> of treating tx_queue_len isn't right: it can be changed after
> initialization too, and looks like perfect way to control the queue
> size globally. Anyway, current use of "limit" parameter in sfq warps
> its idea. Another possibility would be like this:
> 
> sch->q.qlen >= max_t(__u32, sch->dev->tx_queue_len, q->limit)
> 
> or removing this global sch->q.qlen check at all. Or maybe we need to
> add one more tc parameter for sfq?


I would go for a new parameter, tx_queue_len is not very well
suited in my opinion since its global for the entire device,
and most likely you don't want inner qdiscs to have the full
tx_queue_length as limit but something smaller.
