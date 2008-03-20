From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Does HTB traffic shaping happen on leaf classes only or could
	it happen at root qdisc
Date: Thu, 20 Mar 2008 20:49:37 +0100
Message-ID: <20080320194937.GA3193@ami.dom.local>
References: <4a9dfdec0803180539wb2f9dc7n18cac81a2fe92345@mail.gmail.com> <20080320115100.GB4037@ff.dom.local> <4a9dfdec0803200707v15f65d8oba1933f1b20e406c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Djalel Chefrour <cdjalel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:47637 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbYCTTpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 15:45:09 -0400
Received: by rv-out-0910.google.com with SMTP id k20so561315rvb.1
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 12:45:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4a9dfdec0803200707v15f65d8oba1933f1b20e406c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2008 at 03:07:05PM +0100, Djalel Chefrour wrote:
...
> >  > # tc -s -d class show dev ppp0
> >  > class htb 1:110 parent 1:10 leaf 110: prio 0 quantum 1375 rate 110Kbit
> >  > ceil 220Kbit burst 323b/2 mpu 0b overhead 18b atm cburst 392b/2 mpu 0b
> >
> >  Are these default quantum, burst and cburst parameters?
> >
> Yes they are. I forget to mention that I am also using tc-atm pacth with:
> atm overhead 18 nohys mtu 256, for 1:10
> atm overhead 18 nohys, for 1:20

I don't know this patch, but if it's about some fine graining, maybe
it's better to get it working with a vanilla version first. Anyway,
you wondered why 1:110 could be treated unfair vs. 1:20, so I wonder,
why it has worse parameters than 1:20 (also by default?).

> >  > overhead 18b atm level 0
> >  >  Sent 3888361 bytes 19368 pkts (dropped 0, overlimits 0)
> >  >  rate 7160bit 35pps
> >  >  lended: 19348 borrowed: 20 giants: 50
> >
> >  giants (>mtu) means something goes out of band here.
> >
> Hmmm, that could be explained with mtu set to 256

I'm not sure where you set this mtu, or if it's changed by this atm
patch, but HTB gets packets bigger than it can rate, so you probably
should set HTB's mtu parameter higher, until these giants are not
reported.

> >  No, HTB root qdisc doesn't even have parameter for shaping.
> >  BTW, did you read this fine manual?:
> >  http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm
> >
> 
> Yes, thats what I read too, but the output shows 0 overlimits for all
> nodes but root !!!
> So how to interpret this?

I'm not sure if HTB uses these overlimits for classes yet. But, I
don't see why should you care about this so much: it only tells
generally how much classes delay sending - not about overloading.

If I don't miss something in your problem, you should check first
if 1:110 class works OK without any traffic in 1:20, and if so, than
limit 1:20 parameters until it doesn't affect 1:110 anymore.

Jarek P.
