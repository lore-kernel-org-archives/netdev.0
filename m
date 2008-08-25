From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 00:48:25 -0700 (PDT)
Message-ID: <20080825.004825.193701182.davem@davemloft.net>
References: <20080824191905.GA3372@ami.dom.local>
	<20080824.174949.118585414.davem@davemloft.net>
	<20080825060640.GA2633@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752561AbYHYHs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 03:48:29 -0400
In-Reply-To: <20080825060640.GA2633@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 25 Aug 2008 06:06:40 +0000

> It seems the priority can really be misleading here. Do you mean these
> hwqueues are internally prioritized too? This would be strange to me,
> because why would we need this independent locking per hwqueue if
> everything has to wait for the most prioritized hwqueue anyway? And,
> if so, current dev_pick_tx() with simple_tx_hash() would always harm
> some flows directing them to lower priority hwqueues?!

Yes some can do internal prioritization in hardware.

But even if not, this means even if the card does flow based
multiqueue, this is still the right thing to do.

Think about what actually happens on the wire as a result of
our actions, rather than intuition :-)

> But, even if it's true, let's take a look at fifo: a packet at the
> head of the qdisc's queue could be hashed to the last hwqueue. If
> it's stopped for some reason, this packed would be constantly
> requeued blocking all other packets, while their hwqueues are ready
> and empty!

If we feed packets after the first one to the card, we would not
be implementing a FIFO.
