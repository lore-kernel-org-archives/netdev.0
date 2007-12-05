From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] netns: Tag the network flow with the network
 namespace it is in (v2)
Date: Wed, 05 Dec 2007 02:10:36 -0800 (PST)
Message-ID: <20071205.021036.22032476.davem@davemloft.net>
References: <20071204095333.GA6029@iris.sw.ru>
	<20071204062605.508cf812@shemminger-laptop>
	<47559FA9.2080109@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, den@openvz.org, devel@openvz.org,
	netdev@vger.kernel.org, containers@lists.osdl.org
To: den@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751422AbXLEKKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:10:37 -0500
In-Reply-To: <47559FA9.2080109@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@sw.ru>
Date: Tue, 04 Dec 2007 21:42:49 +0300

> Stephen Hemminger wrote:
> > Can this be made conditional on network namespaces being configured on?
> > That way the flow structure won't have to grow taking more space.
> > It matters in DoS attacks where flow cache becomes a critical resource.
> 
> could you exactly point me out the flow cache your are talking about.
> Is this dst entry cache or struct flow_cache described in the
> net/core/flow.c
> 
> For the latter case, there is completely no difference in the size on my
> x86_64 host with SLAB allocator, i.e. there are 30 objects per slab
> with/without fl_net (objsize = 128).

This may be true, but another thing to consider is that flow
objects sit on the stack in many call sites.

I won't let this block your patch, but I want you to be cognizant
of this issue in the future, it's not all about SLAB.

You should also BTW consider how this change will effect D-cache
access patterns and L2 cache utilization.  Some object access
patterns may not fit in the cache, which did beforehand, which
can kill performance.  We're talking about something which gets
touched multiple times per packet at routing rates in the
million packet per second range.
