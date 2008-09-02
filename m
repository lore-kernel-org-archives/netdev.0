From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
	scheduler support
Date: Tue, 2 Sep 2008 22:09:53 +0200
Message-ID: <20080902200953.GA2544@ami.dom.local>
References: <20080901210516.GA5931@ami.dom.local> <1220309354.14337.34.camel@ahduyck-laptop> <20080902055411.GA4180@ff.dom.local> <20080902075241.GB4180@ff.dom.local> <80769D7B14936844A23C0C43D9FBCF0F1525E3CA@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:55574 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbYIBUJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 16:09:38 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1946556fkq.5
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 13:09:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F1525E3CA@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2008 at 10:18:36AM -0700, Duyck, Alexander H wrote:
> Jarek Poplawski wrote:
> > On Tue, Sep 02, 2008 at 05:54:11AM +0000, Jarek Poplawski wrote:
> > ...
> >> OK, but I wonder if it's not enough to treat this as a
> >> recommendation? Actually, since dequeuing is under the common lock
> >> here, the main difference seems to be this checking for
> >> subqueue_stopped could happen a bit earlier,
> >
> > Hmm.., actually a bit later... Then this should be a bit more exact?!
> > Anyway, still looks safe to me.
> >
> > Jarek P.
> 
> Let me give an example of how this can go wrong.  Lets say we use multiq as a leaf for each band in prio and two different bands have a packet for hw queue 1.  If prio band 0 tries to pull and the leaf finds that queue 1 is stopped then dequeue returns null.  A tx interrupt fires and the driver then wakes queue 1 since space is available.  Then prio pull from band 1 and enqueues the packet on hw queue 1.  The end result is the lower priority packet slipping in before the higher priority packet in the hardware queue.
> 
> The advantage to making this qdisc root is that you then have exactly one qdisc band per hardware queue.  You can then place whatever qdiscs you want on each of the bands and the behavior will be consistent per queue.
> 

Right. But since this doesn't cause this additional blocking I'm not
sure there is a reason to forbid this. IMHO documenting this could be
enough, and letting to do this could be useful even for testing. But,
of course, you are the author, so I don't persist with this.

Thanks,
Jarek P.
