From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Send ICMPv6 RSes only when RAs are accepted
Date: Fri, 16 Sep 2011 17:49:00 -0400 (EDT)
Message-ID: <20110916.174900.961553137813655280.davem@davemloft.net>
References: <201108291209.p7TC9KkD002967@wrath.fud.no>
	<20110916.171503.42153974977438913.davem@davemloft.net>
	<4E73C2E5.2050901@fud.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tore@fud.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250Ab1IPVuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 17:50:08 -0400
In-Reply-To: <4E73C2E5.2050901@fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tore Anderson <tore@fud.no>
Date: Fri, 16 Sep 2011 23:43:01 +0200

> * David Miller
> 
>> From: Tore Anderson <tore@fud.no>
>> Date: Mon, 29 Aug 2011 14:08:33 +0200
>> 
>>> The change also makes "Hybrid Router" forwarding mode ("forwarding"
>>> sysctl set to 2) redundant, as the only thing that distinguished it from
>>> the standard Router mode (forwarding=1) was that RSes was being sent. It
>>> has therefore been removed.
>> 
>> You're not removing "accept_ra==2", it's still there in the test:
>> 
>>> -	if ((ifp->idev->cnf.forwarding == 0 ||
>>> -	     ifp->idev->cnf.forwarding == 2) &&
>>> +	if (((ifp->idev->cnf.accept_ra == 1 && !ifp->idev->cnf.forwarding) ||
>>> +	     ifp->idev->cnf.accept_ra == 2) &&
>> 
>> And it does provide it's own unique behavior compared to
>> "accept_ra==1".
> 
> Hi David,
> 
> I'm not removing accept_ra==2, no, only forwarding==2. Or, more
> precisely, I'm only removing the *documentation* for forwarding==2;
> forwarding==2 will still work, but there's no difference from
> forwarding==1 any longer.

Ok, please make this more clear in your commit message.

Thank you.
