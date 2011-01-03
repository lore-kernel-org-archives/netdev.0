From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Mon, 3 Jan 2011 09:58:42 -0800
Message-ID: <20110103095842.7677130d@nehalam>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	<20101220232020.GB2052@del.dom.local>
	<1292887689.2627.150.camel@edumazet-laptop>
	<20101220235209.GA1865@del.dom.local>
	<1292939574.6535.27.camel@mojatatu>
	<AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	<20101221223704.GA1979@del.dom.local>
	<1293111333.11306.170.camel@mojatatu>
	<1294003631.2535.253.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35794 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365Ab1ACR6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 12:58:45 -0500
In-Reply-To: <1294003631.2535.253.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Jan 2011 22:27:11 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> While playing with SFQ and other AQM, I was bothered to see how easy it
> was for a single tcp flow to 'fill the pipe' and consume lot of memory
> buffers in queues. I know Jesper use more than 50.000 SFQ on his
> routers, and with GRO packets this can consume a lot of memory.
> 
> I played a bit adding ECN in SFQ, first by marking packets for a
> particular flow if this flow qlen was above a given threshold, and later
> using another trick : ECN mark packet if it stayed longer than a given
> delay in the queue. This of course could be done on other modules, what
> do you think ?
> 
> The idea is to take into account the time packet stayed in the queue,
> regardless of other class parameters.
> 
> Following quick and dirty patch to show the idea. Of course, the delay
> should be configured on each SFQ/RED/XXXX class, so it would need an
> iproute2 patch, and the delay unit should be "ms" (or even "us"), not
> ticks, but as I said this is a quick and dirty patch (net-next-2.6
> based)
> 
> Using jiffies allows only delays above 3 or 4 ticks...
> 
> Or maybe ECN is just a dream :(

You might want to look into CHOKe and ECSFQ which are other AQM models
that have shown up in research.


-- 
