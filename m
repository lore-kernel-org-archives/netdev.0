From: David Miller <davem@davemloft.net>
Subject: Re: return of ip_rt_bug()
Date: Thu, 11 Aug 2011 06:00:57 -0700 (PDT)
Message-ID: <20110811.060057.36747750681761864.davem@davemloft.net>
References: <alpine.LFD.2.00.1108070104440.1413@ja.ssi.bg>
	<20110807.222042.1034530719366562334.davem@davemloft.net>
	<alpine.LFD.2.00.1108091645351.1527@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: selinux@gmail.com, davej@redhat.com, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482Ab1HKNBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 09:01:12 -0400
In-Reply-To: <alpine.LFD.2.00.1108091645351.1527@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 9 Aug 2011 16:51:26 +0300 (EEST)

> 	There are other places that used fl.iif (0 for output
> routes) but are now using rt_iif instead of rt_route_iif,
> not sure if this change is fatal for them because:
> 
> - net/sched/cls_route.c, route4_classify() gets optional
> iif, so it can be 0, may be to match output route? And
> later route4_classify does exact match for rt_iif. Does
> it mean that now we can not match output packets without
> providing "fromif OUTDEV" ?
> 
> - net/sched/em_meta.c: now int_rtiif (being rt_iif) is
> always != 0, may be not good to match output routes?
> 
> 	In short, the fl.iif -> rt_iif conversion is risky
> at some places.

If we convert em_meta.c and cls_route.c to use rt_route_iif
we should be OK right?  Please patches to do this if so.

Thanks.
