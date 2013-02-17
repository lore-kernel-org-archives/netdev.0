From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tuntap: Overload handling
Date: Sun, 17 Feb 2013 15:24:04 +0200
Message-ID: <20130217132404.GA22552@redhat.com>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
 <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
 <1360859547.6884.51.camel@edumazet-glaptop>
 <20130214164053.GB18721@redhat.com>
 <1360861290.6884.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian =?iso-8859-1?Q?P=F6hn?=
	<sebastian.poehn@googlemail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755870Ab3BQNYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 08:24:09 -0500
Content-Disposition: inline
In-Reply-To: <1360861290.6884.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 09:01:30AM -0800, Eric Dumazet wrote:
> On Thu, 2013-02-14 at 18:42 +0200, Michael S. Tsirkin wrote:
> 
> > Hmm so ~1000 packets in the tun queue is not enough?
> > You always have the option to increase it some more ...
> > 
> > > You should ask Michael S. Tsirkin, as he removed the flow control
> > > in commit 5d097109257c03a71845729f8db6b5770c4bbedc
> > > (tun: only queue packets on device)
> > > 
> > 
> > Eric in the past you said the following things
> > (http://lkml.indiana.edu/hypermail/linux/kernel/1204.1/00784.html)
> > > > In your case I would just not use qdisc at all, like other virtual
> > > > devices.
> > ...
> > > > Anyway, with a 500 packet limit in TUN queue itself, qdisc layer should
> > > > be always empty. Whats the point storing more than 500 packets for a
> > > > device ? Thats a latency killer.
> > you don't think this applies, anymore?
> > 
> 
> Users have the choice to setup a qdisc or not.
> 
> Having no qdisc can help raw performance, at the expense of bufferbloat.
> Thats all I was saying.
> 
> It seems tun.c has no longer the possibility to effectively use a qdisc,
> (allowing the queue to buildup at qdisc layer)
> 

But, userspace is in no position to decide whether using
the qdisc is a good or a bad thing.
The issue I tried to solve is that with tun, it's trivially easy for
userspace to lock up resources forever.
Simply not stopping the qdisc is probably the simplest solution.

An alternative is to orphan the skbs before we queue them.
At some point I posted a proposal doing exactly this
subj of "net: orphan queued skbs if device tx can stall".
Do you think it's worth revisiting this?

Also - does anyone know of a testcase showing there's a problem
with the simplest solution we now have in place?

-- 
MST
