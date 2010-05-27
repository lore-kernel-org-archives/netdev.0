From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 09:57:18 +0200
Message-ID: <20100527075717.GA6800@basil.fritz.box>
References: <87fx1e1sat.fsf@basil.nowhere.org> <20100526.140818.245406045.davem@davemloft.net> <20100526212745.GC24615@basil.fritz.box> <20100526.151014.70204145.davem@davemloft.net> <4BFDA0B6.8030701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, David Miller <davem@davemloft.net>,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	ycheng@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47514 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428Ab0E0H5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 03:57:23 -0400
Content-Disposition: inline
In-Reply-To: <4BFDA0B6.8030701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Then all the app does is say "I'am in peer id foo" right?  Is that really 
> that much different from making the setsockopt() call for a different cwnd 
> value? Particularly if say the limit were not a global sysctl, but based on 
> the existing per-route value (perhaps expanded to have a min, max and 
> default?)

The worst case with peer id would be app using an own peer id
for each connection. So each connection would have an own cwnd,
just like today. So the worst case is the same as today.

If it shares connections between peer ids the real effective cwnd
of all those connections would be also never be "worse" (that is
larger) than it could be on single connection. 

So this limits the cwnds effectively with peer ids, although it also 
gives a nice way to reuse an already existing cwnd for a new
connection (this does not make things worse because in theory
the app could have reused the same connection too) 

So overall peer ids don't allow to enlarge cwnds over today.

If the cwnd is fully application controlled all these limits
are not there and a bittorrent client could just always set 
it to 1 million.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
