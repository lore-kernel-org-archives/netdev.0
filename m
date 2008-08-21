From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 10:18:30 +0000
Message-ID: <20080821101830.GB3963@ff.dom.local>
References: <20080819085504.GB29038@gondor.apana.org.au> <20080819091642.GI4376@ff.dom.local> <20080821100155.GA3621@ff.dom.local> <20080821.030523.205239441.davem@davemloft.net> <20080821101145.GA3963@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:56009 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbYHUKSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 06:18:37 -0400
Received: by fk-out-0910.google.com with SMTP id 18so584670fkq.5
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 03:18:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821101145.GA3963@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 10:11:45AM +0000, Jarek Poplawski wrote:
> On Thu, Aug 21, 2008 at 03:05:23AM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Thu, 21 Aug 2008 10:01:55 +0000
> > 
> > > If we do this with child qdisc from qdisc_graft() it's without
> > > deactivation. The rest of the tree can be dequeued in the meantime
> > > and call qdisc_tree_decrease_qlen() (like hfsc, tbf, netem), which
> > > uses qdisc_lookup() to access this list. We list_del() under rtnl
> > > lock only, they lookup under sch_tree_lock(). Is it a bit unsafe
> > > or I miss something?
> > 
> > They hold RTNL as well.
> > 
> > Remember, sch_tree_lock() uses qdisc_root_lock() which as I've
> > told you at least twice now asserts that RTNL is held :-)
> 
> Actually, I've called it wrong, they hold qdisc root lock, but they
> certainly can't have rtnl_lock() at the moment!

I mean here: hfsc_dequeue(), netem_dequeue() and tbf_dequeue().

Jarek P.
