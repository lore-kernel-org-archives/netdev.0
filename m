From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Mon, 03 Jan 2011 08:52:35 -0500
Message-ID: <1294062755.2472.11.camel@mojatatu>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59973 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129Ab1ACNxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 08:53:09 -0500
Received: by vws16 with SMTP id 16so5745170vws.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 05:53:09 -0800 (PST)
In-Reply-To: <1294003631.2535.253.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-01-02 at 22:27 +0100, Eric Dumazet wrote:
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

I think for this to be effective, it would require maintaining some
history of the effect (some form of moving window average)
and probably a randomness in marking instead of a deterministic one.
Something like what Stochastic Fair RED/BLUE Queueing does.
Otherwise you get a burst of marked packets then silence then a burst
etc (i.e the classical synchronization effect).

It would probably be more effective to provide feedback to the local tcp
since we can detect this locally instead of waiting to some round trip
(or half roundtrip) effect at the receiver with ECN i.e in the same
spirit as NET_XMIT_CN but for which local TCP does something useful with
that info (instead of "retransmit shortly"). But even that would require
maintaining some state on the scheduler per hash in this case....

cheers,
jamal


