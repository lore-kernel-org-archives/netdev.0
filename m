From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Fri, 13 Jul 2007 15:42:32 +0200
Message-ID: <20070713134231.GC3282@ff.dom.local>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net> <20070712073746.GA1708@ff.dom.local> <1184231903.3477.65.camel@ranko-fc2.spidernet.net> <20070712104641.GB1708@ff.dom.local> <1184240842.3477.110.camel@ranko-fc2.spidernet.net> <46961970.7080209@trash.net> <1184262525.3477.135.camel@ranko-fc2.spidernet.net> <20070713121733.GB3282@ff.dom.local> <1184329602.16732.16.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:59136 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757142AbXGMNdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 09:33:46 -0400
Content-Disposition: inline
In-Reply-To: <1184329602.16732.16.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 03:26:42PM +0300, Ranko Zivojnovic wrote:
> On Fri, 2007-07-13 at 14:17 +0200, Jarek Poplawski wrote:
> > On Thu, Jul 12, 2007 at 08:48:45PM +0300, Ranko Zivojnovic wrote:
> > ...
> > > Ok - here's the patch for a review - it compiles clean ... and that's as
> > > much as it has been tested - I'll try give it a run later today or
> > > definitely tomorrow.
> > ...
> > 
> > Ranko, you have some powers!
> > 
> > Alas, I definitely need more time. I hope I'll manage to check this
> > till monday. Of course, if testing will be OK and somebody will check
> > and ack this earlier I don't see any reason in waiting on my opinion.
> 
> Don't bother - just tested and it is a no-go (it would have been a
> wander if it worked from the first time :)) - have to resolve the issues
> with qdiscs that do not calculate/use rates...
> 
> I'm not sure if it is desirable to have rates available on all qdiscs -
> even on pfifo_fast... that way, when you issue...
> 
> # tc -s qdisc show dev eth0
> qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 115971059 bytes 196761 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> ...you will not get the 'rate 0bit'.
> 

I've been a bit tight on time today, and only now I see that maybe
you have done too much. Of course, you can do it your way, but I
think it should be easier not change too much at once, so if possible
only include structs bstats and rate_est into struct gen_estimator
and do otherwise in these few sch_'s and act_'s which use this plus
all acceses and allocs changed appropriately. So it should be only 6
or 7 files affected. It seems no changes about gen_stats are necessary
now (next patch?).

I really can't check more now (or answer until monday).

Bye,
Jarek P.

PS: I'm in a little hurry now so I hope I'm not very wrong above...
