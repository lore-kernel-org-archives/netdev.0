From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 16:15:04 -0700 (PDT)
Message-ID: <20080827.161504.183610665.davem@davemloft.net>
References: <20080827223410.GC26610@one.firstfloor.org>
	<20080827.153907.157997966.davem@davemloft.net>
	<48B5DE9F.4010000@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753563AbYH0XPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 19:15:09 -0400
In-Reply-To: <48B5DE9F.4010000@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 28 Aug 2008 01:09:19 +0200

> Not really, I suspect commit (a7ab4b501f9b8a9dc4d5cee542db67b6ccd1088b [TCPv4]: Improve BH latency in /proc/net/tcp) is responsible for longer delays.
> Note that its rather old :
 ...
> We used to disable bh once, while reading the table. This sucked.
> 
> In case machine is handling trafic, we now are preemptable by softirqs
> while reading /proc/net/tcp. Thats a good thing.

Yes, that would account for it, good spotting.

> By the way, I find Andi patch usefull. Same thing could be done for /proc/net/rt_cache.

Fair enough.  If you can cook up a quick rt_cache patch I'll toss it and
Andi's patch into net-next so it can cook for a while.
