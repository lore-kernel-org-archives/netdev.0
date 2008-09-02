From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
	scheduler support
Date: Tue, 2 Sep 2008 05:54:11 +0000
Message-ID: <20080902055411.GA4180@ff.dom.local>
References: <20080901210516.GA5931@ami.dom.local> <1220309354.14337.34.camel@ahduyck-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jeff@garzik.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:53910 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbYIBFyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 01:54:17 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1845146fgg.17
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2008 22:54:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1220309354.14337.34.camel@ahduyck-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 01, 2008 at 03:49:14PM -0700, Alexander Duyck wrote:
> On Mon, 2008-09-01 at 23:05 +0200, Jarek Poplawski wrote:
> 
> > Mostly looks OK to me, but a few (late) doubts below:
> 
> Most of your suggestions I agree with, with the following exceptions.
> > ...
> > > +static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
> > > +{
> > > +	struct multiq_sched_data *q = qdisc_priv(sch);
> > > +	struct tc_multiq_qopt *qopt;
> > > +	struct Qdisc **queues;
> > > +	int i;
> > > +
> > > +	if (sch->parent != TC_H_ROOT)
> > > +		return -EINVAL;
> > 
> > Is it necessary?
> > 
> I think so.  Basically I want to have this qdisc as the root for all
> other qdiscs because the hardware queue decision needs to be made as
> soon as possible in order to avoid any head of line blocking issues.
> This way you don't end up with multiple qdiscs fighting over hardware
> queues.

OK, but I wonder if it's not enough to treat this as a recommendation?
Actually, since dequeuing is under the common lock here, the main
difference seems to be this checking for subqueue_stopped could happen
a bit earlier, but this should be safe (a subqueue can't get another
packets in the meantime). So maybe I miss something but this looks
like blocking safe even when used as prio's leaf.

Thanks,
Jarek P.
