From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 01:56:12 -0700 (PDT)
Message-ID: <20120626.015612.985388265386248330.davem@davemloft.net>
References: <1340698984.10893.248.camel@edumazet-glaptop>
	<20120626.013730.902797211256084220.davem@davemloft.net>
	<1340700408.10893.275.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab2FZI4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:56:13 -0400
In-Reply-To: <1340700408.10893.275.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Jun 2012 10:46:48 +0200

> On Tue, 2012-06-26 at 01:37 -0700, David Miller wrote:
> 
>> And think, we don't do any stupidity like this for the inetpeer cache
>> and no small cute animals have died as a result.
> 
> Thats because inetpeer is kept small.
> 
> We do have a smart gc on inetpeer cache (inet_peer_gc()),
> and inetpeer threshold is 65536 

Fair enough.

Keep in mind that rt_check_expire() was written before we had realtime
GC.  It used to be main component which kept hash chains of reasonable
size before real ->gc() triggers.

I have about 15 entries in my routing cache, there is no reason they
should be purged.

And consider TCP before early demux, so a connection doing financial
trades is idle for 5 minutes.  Do you really think the next trade
should have this pointless added latency just because we can't be
bothered to make rt_check_expired() smarter?
