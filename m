From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including destination address in the hash key
Date: Thu, 5 Nov 2009 15:54:28 +0100
Message-ID: <20091105145428.GS31511@one.firstfloor.org>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com> <200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com> <877hu5892g.fsf@basil.nowhere.org> <4AF2CCD9.7010507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58159 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757771AbZKEOy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 09:54:27 -0500
Content-Disposition: inline
In-Reply-To: <4AF2CCD9.7010507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I assume cache is cold or even on other cpu (worst case), dealing with
> 100.000+ sockets or so...

Other CPU cache hit is actually typically significantly 
faster than a DRAM access (unless you're talking about a very large NUMA 
system and a remote CPU far away)
> 
> If workload fits in one CPU cache/registers, we dont mind taking one
> or two cache lines per object, obviously.

It's more like part of your workload needs to fit.

For example if you use a tree and the higher levels fit into
the cache, having a few levels in the tree is (approximately) free.

That's why I'm not always fond of large hash tables. They pretty
much guarantee a lot of cache misses under high load, because
they have little locality.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
