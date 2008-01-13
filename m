From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH/RFC] synchronize_rcu(): high latency on idle system
Date: Sat, 12 Jan 2008 17:52:26 -0800
Message-ID: <20080112175226.7d8f9dbc@deepthought>
References: <20080112012626.GI28570@kvack.org>
	<20080112023759.GG21068@bingen.suse.de>
	<20080112175135.GK28570@kvack.org>
	<200801121935.58286.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kerne@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53050 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbYAMBzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 20:55:07 -0500
In-Reply-To: <200801121935.58286.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Jan 2008 19:35:58 +0100
Andi Kleen <ak@suse.de> wrote:

> On Saturday 12 January 2008 18:51:35 Benjamin LaHaise wrote:
> > On Sat, Jan 12, 2008 at 03:37:59AM +0100, Andi Kleen wrote:
> > > > And yes, the 
> > > > network stack shouldn't call synchronize_rcu() quite so much, but fixing that 
> > > > is a little more involved.
> > > 
> > > ... but the correct solution.
> > 
> > There has to be at least 1 synchronize_rcu() or equivalent in the 
> > unregister_netdev() path.  I suspect the easiest way to fix it might be to 
> > use call_rcu() to actually free the network device, as anything else will 
> > limit performance of single threaded teardown (ie, when an l2tp daemon 
> > gets terminated via kill -9).  This means an API change that exposes 
> > rcu for unregister_netdev().
> 
> The call_rcu() could be in free_netdev() couldn't it?

I think it should be in netdev_unregister_kobject().  But that would
only get rid of one of the two calls to synchronize_rcu() in the unregister_netdev.
The other synchronize_rcu() is for qdisc's and not sure if that one can
be removed?


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
