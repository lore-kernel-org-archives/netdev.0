From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 07:57:44 +0000
Message-ID: <20080825075744.GC2633@ff.dom.local>
References: <20080824191905.GA3372@ami.dom.local> <20080824.174949.118585414.davem@davemloft.net> <20080825060640.GA2633@ff.dom.local> <20080825.004825.193701182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:12610 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334AbYHYH5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 03:57:51 -0400
Received: by ug-out-1314.google.com with SMTP id c2so466976ugf.37
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 00:57:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080825.004825.193701182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2008 at 12:48:25AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 25 Aug 2008 06:06:40 +0000
> 
> > It seems the priority can really be misleading here. Do you mean these
> > hwqueues are internally prioritized too? This would be strange to me,
> > because why would we need this independent locking per hwqueue if
> > everything has to wait for the most prioritized hwqueue anyway? And,
> > if so, current dev_pick_tx() with simple_tx_hash() would always harm
> > some flows directing them to lower priority hwqueues?!
> 
> Yes some can do internal prioritization in hardware.
> 
> But even if not, this means even if the card does flow based
> multiqueue, this is still the right thing to do.
> 
> Think about what actually happens on the wire as a result of
> our actions, rather than intuition :-)
> 
> > But, even if it's true, let's take a look at fifo: a packet at the
> > head of the qdisc's queue could be hashed to the last hwqueue. If
> > it's stopped for some reason, this packed would be constantly
> > requeued blocking all other packets, while their hwqueues are ready
> > and empty!
> 
> If we feed packets after the first one to the card, we would not
> be implementing a FIFO.

Not necessarilly so: if separate flows are hashed to "their" hwqueues,
a FIFO per flow would be still obeyed.

Jarek P.
