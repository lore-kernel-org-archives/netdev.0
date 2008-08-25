From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sun, 24 Aug 2008 17:49:49 -0700 (PDT)
Message-ID: <20080824.174949.118585414.davem@davemloft.net>
References: <20080824075331.GA2721@ami.dom.local>
	<1219585163.4698.43.camel@localhost>
	<20080824191905.GA3372@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751355AbYHYAty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 20:49:54 -0400
In-Reply-To: <20080824191905.GA3372@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 24 Aug 2008 21:19:05 +0200

> On Sun, Aug 24, 2008 at 09:39:23AM -0400, jamal wrote:
> ...
> > With current controls being per qdisc instead of per netdevice,
> > the hol fear is unfounded. 
> > You send and when hw cant keep up, you block just the one hwqueue.
> > While hwqueue is blocked, you can accumulate packets in the prio qdisc
> > (hence my statement it may not be necessary to accumulate packets in
> > driver).
> 
> Jamal, maybe I miss something, but this could be like this only with
> default pfifo_fast qdiscs, which really are per dev hwqueue. Other
> qdiscs, including prio, are per device, so with prio, if a band with
> the highest priority is blocked it would be requeued blocking other
> bands (hwqueues in Alexander's case).

It only blocks if the highest priority band's HW queue is blocked, and
that's what you want to happen.

Think about it, if the highest priority HW queue is full, queueing
packets to the lower priority queues won't make anything happen.

As the highest priority queue opens up and begins to have space,
we'll feed it high priority packets from the prio qdisc, and so
on and so forth.

This isn't a real issue, and I remember Patrick and Jamal going
back and forth about this some time ago. :-)

