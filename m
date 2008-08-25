From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 06:16:28 +0000
Message-ID: <20080825061628.GB2633@ff.dom.local>
References: <1219585163.4698.43.camel@localhost> <20080824191905.GA3372@ami.dom.local> <20080824192734.GB3372@ami.dom.local> <20080824.175026.237775292.davem@davemloft.net> <5f2db9d90808242003p5e4e1946rebf3a9b3945c7c51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:9648 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbYHYGQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 02:16:34 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1257701ika.5
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 23:16:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5f2db9d90808242003p5e4e1946rebf3a9b3945c7c51@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2008 at 08:03:11PM -0700, Alexander Duyck wrote:
> On Sun, Aug 24, 2008 at 5:50 PM, David Miller <davem@davemloft.net> wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Sun, 24 Aug 2008 21:27:34 +0200
> >
> >> On Sun, Aug 24, 2008 at 09:19:05PM +0200, Jarek Poplawski wrote:
> >> ...
> >> > Jamal, maybe I miss something, but this could be like this only with
> >> > default pfifo_fast qdiscs, which really are per dev hwqueue. Other
> >> > qdiscs, including prio, are per device, so with prio, if a band with
> >> > the highest priority is blocked it would be requeued blocking other
> >> > bands (hwqueues in Alexander's case).
> >>
> >> And, actually, because of this, Alexander is right the prio_dequeue()
> >> can't work like this without any changes.
> >
> > Yes it can, see my other response.  Only the higher priority
> > queues filling up can block lower priority traffic, and that
> > is fine.
> >
> 
> Let's get away from the priority discussion because it doesn't have
> anything to do with what I am talking about.  One of the main reasons
> why I am thinking it might be wise to move this out of the prio qdisc
> and spin it off as a qdisc of its own is because what I am trying to
> accomplish doesn't care about the priority of the packet.  All I am
> concerned with is that this qdisc doesn't block the transmit of any
> other hardware queues if one of the hardware queues are blocked and
> that all queues have an equal chance to dequeue packets.
> 
> What I am planning to implement at this point is a simple multi-band
> qdisc that assigns the band number based on queue mapping.  This
> combined with something like the rr_dequeue from the original qdisc
> will resolve the head-of-line issues.  Essentially it will try to
> mimic the way the pfifo_fast qdiscs work with hardware multiqueue, but
> it will have the ability to classify traffic and be stuck with one
> spin lock for all queues.
> 
> I will try to get patches submitted for this new approach to the qdisc
> and the new action in the next day or two.  In the meantime we can
> probably drop this issue for now since I am in agreement that this
> isn't the best approach to resolving this issue.

I agree with you that a separate qdisc, or actually some aliases, like
this older sch_rr, and maybe also independent sch_prio_mq with .enqueue
and .dequeue overridden, look most sensible to me.

Thanks,
Jarek P.
