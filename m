From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Thu, 10 May 2007 15:14:26 -0700
Message-ID: <20070510151426.d808384f.akpm@linux-foundation.org>
References: <20070504232051.411946839@goop.org>
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org>
	<463C56D3.8060609@goop.org>
	<20070505102305.GA12771@gondor.apana.org.au>
	<463F95C3.60407@goop.org>
	<20070508121322.GA21647@gondor.apana.org.au>
	<464395E5.2090500@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>, Valdis.Kletnieks@vt.edu
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:58756 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762720AbXEJWQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 18:16:20 -0400
In-Reply-To: <464395E5.2090500@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007 15:00:05 -0700
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Herbert Xu wrote:
> > [NET] link_watch: Move link watch list into net_device
> >
> > These days the link watch mechanism is an integral part of the
> > network subsystem as it manages the carrier status.  So it now
> > makes sense to allocate some memory for it in net_device rather
> > than allocating it on demand.
> 
> I think there's a problem with one of these two patches.  I've been
> noticing that one of my events/X threads has been going into a spin for
> about 5 mins after boot.  I added some debugging to
> kernel/workqueue.c:run_workqueue, since its that loop which seems to be
> spinning due to list corruption.
> 
> When I look to see if that loop has iterated for more than 100 times in
> one go (which seems unlikely),  I get this:
> 
> BUG: cpu 3, count=101 list screwup on c04babe4, func c03217e8
> func=linkwatch_event+0x0/0x2a
>  [<c0109173>] show_trace_log_lvl+0x1a/0x30
>  [<c0109c7f>] show_trace+0x12/0x14
>  [<c0109d0c>] dump_stack+0x16/0x18
>  [<c0137c25>] run_workqueue+0x97/0x18c
>  [<c01386a4>] worker_thread+0xe5/0xf5
>  [<c013afe9>] kthread+0x3b/0x62
>  [<c0108d47>] kernel_thread_helper+0x7/0x10
>  =======================
> 
> 
> I wonder if the problem is that the linkwatch_work is being rescheduled
> when its already been scheduled, or something like that?

Five minutes after boot is when jiffies wraps.  Are you sure it's
a list-screwup rather than a jiffy-wrap screwup?
