From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 10:11:02 -0800
Message-ID: <4970CDB6.6040705@hp.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>	<200901161503.13730.nickpiggin@yahoo.com.au>	<20090115201210.ca1a9542.akpm@linux-foundation.org> <200901161746.25205.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, matthew@wil.cx, matthew.r.wilcox@intel.com,
	chinang.ma@intel.com, linux-kernel@vger.kernel.org,
	sharad.c.tripathi@intel.com, arjan@linux.intel.com,
	andi.kleen@intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:43335 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935894AbZAPSLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 13:11:10 -0500
In-Reply-To: <200901161746.25205.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Piggin wrote:
> OK, I have these numbers to show I'm not completely off my rocker to suggest
> we merge SLQB :) Given these results, how about I ask to merge SLQB as default
> in linux-next, then if nothing catastrophic happens, merge it upstream in the
> next merge window, then a couple of releases after that, given some time to
> test and tweak SLQB, then we plan to bite the bullet and emerge with just one
> main slab allocator (plus SLOB).
> 
> 
> System is a 2socket, 4 core AMD. 

Not exactly a large system :)  Barely NUMA even with just two sockets.

> All debug and stats options turned off for
> all the allocators; default parameters (ie. SLUB using higher order pages,
> and the others tend to be using order-0). SLQB is the version I recently
> posted, with some of the prefetching removed according to Pekka's review
> (probably a good idea to only add things like that in if/when they prove to
> be an improvement).
> 
> ...
 >
> Netperf UDP unidirectional send test (10 runs, higher better):
> 
> Server and client bound to same CPU
> SLAB AVG=60.111 STD=1.59382
> SLQB AVG=60.167 STD=0.685347
> SLUB AVG=58.277 STD=0.788328
> 
> Server and client bound to same socket, different CPUs
> SLAB AVG=85.938 STD=0.875794
> SLQB AVG=93.662 STD=2.07434
> SLUB AVG=81.983 STD=0.864362
> 
> Server and client bound to different sockets
> SLAB AVG=78.801 STD=1.44118
> SLQB AVG=78.269 STD=1.10457
> SLUB AVG=71.334 STD=1.16809
 > ...
> I haven't done any non-local network tests. Networking is the one of the
> subsystems most heavily dependent on slab performance, so if anybody
> cares to run their favourite tests, that would be really helpful.

I'm guessing, but then are these Mbit/s figures? Would that be the sending 
throughput or the receiving throughput?

I love to see netperf used, but why UDP and loopback?  Also, how about the 
service demands?

rick jones
