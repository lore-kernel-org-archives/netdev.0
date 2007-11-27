From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 12:58:49 +0100
Message-ID: <20071127115849.GA3427@ff.dom.local>
References: <636518.43765.qm@web51402.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42802 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754306AbXK0LyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 06:54:14 -0500
Content-Disposition: inline
In-Reply-To: <636518.43765.qm@web51402.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 02:54:10AM -0800, Joerg Pommnitz wrote:
> Jarek,
> this is all about outgoing packets, e.g. egress to use your word.
> It doesn't matter whether the packets are originated locally or
> whether the packets are forwarded from another host (I tried
> both).
> 
> To restate the problem: according to my observations the prio qdisc
> (and probably pfifo_fast, but I couldn't observe this) does not prioritize
> at all and always uses the band indicated by the first entry in the
> priomap.
> 
> By default the priomap looks like this:
> qdisc prio 1: dev eth1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> 
> there are 3 bands (1:1, 1:2 and 1:3). In theory the traffic should go through
> the different bands according to the TOS value of the packets. My observation
> is, that the traffic always uses the band pointed to by the first entry in the
> priomap. This value is 1 by default, so all traffic goes through band 1:2.
> 
> Now it's entirely possible that I did something stupid, but nobody came forward
> to show me the error of my ways (neither here nor on the lartc list).
> 

I don't think there could be anything stupid if something is maybe not
enough documented. But, this really should work - just like you've
found: TOS should be recalculated to skb->priority, and this should
affect prio. You should only consider that this recalculation isn't
done for all packets, but only forwarded ones (if I can remember, didn't
miss something, and nothing changed later...). So, are you still sure
you've tested such a case? (Btw., there are some other tools which can
change this priority field, so I hope you don't use them too.)

Jarek P.
