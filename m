From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 08:25:02 +0000
Message-ID: <20080825082501.GD2633@ff.dom.local>
References: <20080825060640.GA2633@ff.dom.local> <20080825.004825.193701182.davem@davemloft.net> <20080825075744.GC2633@ff.dom.local> <20080825.010206.193700650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:28003 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbYHYIZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 04:25:09 -0400
Received: by ey-out-2122.google.com with SMTP id 6so161378eyi.37
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 01:25:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080825.010206.193700650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2008 at 01:02:06AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 25 Aug 2008 07:57:44 +0000
> 
> > On Mon, Aug 25, 2008 at 12:48:25AM -0700, David Miller wrote:
> > > From: Jarek Poplawski <jarkao2@gmail.com>
> > > Date: Mon, 25 Aug 2008 06:06:40 +0000
> > > 
> > > If we feed packets after the first one to the card, we would not
> > > be implementing a FIFO.
> > 
> > Not necessarilly so: if separate flows are hashed to "their" hwqueues,
> > a FIFO per flow would be still obeyed.
> 
> What appears on the wire is still going to be similar.
> 
> You have to subsequently ask if it's worth the complexity to do
> what you seem to be proposing.
> 
> When a single hardware queue fills up, it's the SAME, semantically,
> as when a unary TX queue of a traditional device fills up.
> 
> There is NO on the wire difference.  There will be NO performance
> difference, because the device will have work to do as by definition
> of one TX queue being full there are some packets queued up to
> the device.

If with unary TX queue we had to fill one bigger queue (or all TX
queues) before device stopped a qdisc, and with mq TX it's enough to
have one TX filled to effectively stop a qdisc transmit, IMHO there
should be a performance difference.

Jarek P.
