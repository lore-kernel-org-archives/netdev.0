From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Tue, 4 Jan 2011 15:19:26 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
 <20101220232020.GB2052@del.dom.local> <1292887689.2627.150.camel@edumazet-laptop>
 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
 <1294003631.2535.253.camel@edumazet-laptop> <20110103095842.7677130d@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:49912 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409Ab1ADOTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 09:19:33 -0500
In-Reply-To: <20110103095842.7677130d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Jan 2011, Stephen Hemminger wrote:

> On Sun, 02 Jan 2011 22:27:11 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> While playing with SFQ and other AQM, I was bothered to see how easy it
>> was for a single tcp flow to 'fill the pipe' and consume lot of memory
>> buffers in queues. I know Jesper use more than 50.000 SFQ on his
>> routers, and with GRO packets this can consume a lot of memory.

That is true, operations department went kind of crazy when they started 
to add/move customers to our new Nehalem Xeon 5550 systems.  I have 
stopped them now ;-)

The use of an SFQ per customer, actually also solves the buffer bloat 
issue for our customers...


>> I played a bit adding ECN in SFQ, first by marking packets for a
>> particular flow if this flow qlen was above a given threshold, and later
>> using another trick : ECN mark packet if it stayed longer than a given
>> delay in the queue. This of course could be done on other modules, what
>> do you think ?

This is very interesting stuff! :-)

Are you inspired by Jim Gettys buffer bloat discussions?

> ...
> You might want to look into CHOKe and ECSFQ which are other AQM models
> that have shown up in research.

Have you looked at the SFB (Stochastic Fair Blue) implementation by 
Juliusz Chroboczek?

http://www.pps.jussieu.fr/~jch/software/sfb/

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
