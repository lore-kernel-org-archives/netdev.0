From: Julian Anastasov <ja@ssi.bg>
Subject: rt_iif conversions (was Re: return of ip_rt_bug())
Date: Thu, 11 Aug 2011 19:36:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108111919250.1494@ja.ssi.bg>
References: <alpine.LFD.2.00.1108070104440.1413@ja.ssi.bg> <20110807.222042.1034530719366562334.davem@davemloft.net> <alpine.LFD.2.00.1108091645351.1527@ja.ssi.bg> <20110811.060057.36747750681761864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47327 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825Ab1HKQbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 12:31:43 -0400
In-Reply-To: <20110811.060057.36747750681761864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 11 Aug 2011, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Tue, 9 Aug 2011 16:51:26 +0300 (EEST)
> 
> > 	There are other places that used fl.iif (0 for output
> > routes) but are now using rt_iif instead of rt_route_iif,
> > not sure if this change is fatal for them because:
> > 
> > - net/sched/cls_route.c, route4_classify() gets optional
> > iif, so it can be 0, may be to match output route? And
> > later route4_classify does exact match for rt_iif. Does
> > it mean that now we can not match output packets without
> > providing "fromif OUTDEV" ?

	It seems the user space for route filter treats
0 as error, so "fromif if0" was never supported. So, using
rt_iif is a better choice here.

> > - net/sched/em_meta.c: now int_rtiif (being rt_iif) is
> > always != 0, may be not good to match output routes?

	May be using 'rt_iif eq 0' is silly for the meta match.
It is preferred to use rt_iif instead of rt_route_iif so that
one can match even packets from loopback.

> > 	In short, the fl.iif -> rt_iif conversion is risky
> > at some places.
> 
> If we convert em_meta.c and cls_route.c to use rt_route_iif
> we should be OK right?  Please patches to do this if so.

	It seems no patches are needed. Sorry for the confusion.

Regards

--
Julian Anastasov <ja@ssi.bg>
