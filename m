From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 23 Sep 2008 04:12:37 +0200
Message-ID: <20080923021237.GC25711@one.firstfloor.org>
References: <48D82378.4000306@redhat.com> <20080922.161323.108280715.davem@davemloft.net> <20080922232428.GA25711@one.firstfloor.org> <20080922.162158.223213897.davem@davemloft.net> <20080923001409.GB25711@one.firstfloor.org> <48D8396E.20008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, csnook@redhat.com,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49776 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbYIWCHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:07:46 -0400
Content-Disposition: inline
In-Reply-To: <48D8396E.20008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That seems as much of a case against NAT as per-destintation attribute 
> caching.

Sure in a ideal world NAT wouldn't exist. Unfortunately we're 
not in a ideal world.

Also in general my impression is that NAT is becoming more common.
e.g. a lot of the mobile networks seem to be NATed.

> 
> If my experience at "a large company" is any indication, for 99 

My experience at a large company was different. Also see my 
second example.

> 
> And even if I were not, how is per-destination caching the possibly 
> non-optimal characteristics based on one user behind a NAT really 
> functionally different than having to tune the system-wide defaults to 
> cover that corner-case user?  

It's just wasteful on network resouces. e.g. if you start
talking to the slow link with a too large congestion window 
a lot of packets are going to be dropped. Yes TCP will
eventually adapt, but the network and the user performance
suffers and the network is ineffectively used.


> Seems that caching per-destination 
> characteristics is actually limiting the alleged brokenness to that 
> destination rather than all destinations?

Not sure what you're talking about. There's no real brokenness 
in having a slow link.  And with default startup metrics
Linux TCP has no trouble talking to a slow link.

The brokenness is using the dst_entry TCP metrics of a fast link
to talk to a slow link and that happens with NAT.

-Andi

