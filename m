From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [crash] kernel BUG at net/core/pktgen.c:3503!
Date: Tue, 15 Sep 2009 22:51:12 +0400
Message-ID: <20090915185112.GA17587@lenovo>
References: <20090911.202543.52533792.davem@davemloft.net> <20090915183647.GA11628@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:44661 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbZIOSvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 14:51:11 -0400
Content-Disposition: inline
In-Reply-To: <20090915183647.GA11628@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Ingo Molnar - Tue, Sep 15, 2009 at 08:36:47PM +0200]
| 
| not sure which merge caused this, but i got this boot crash with latest 
| -git:
| 
| calling  flow_cache_init+0x0/0x1b9 @ 1
| initcall flow_cache_init+0x0/0x1b9 returned 0 after 64 usecs
| calling  pg_init+0x0/0x37c @ 1
| pktgen 2.72: Packet Generator for packet performance testing.
| ------------[ cut here ]------------
| kernel BUG at net/core/pktgen.c:3503!
| invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
| last sysfs file: 
| 

Hi Ingo,

just curious, will the following patch fix the problem?
I've been fixing problem with familiar symthoms on
system with custome virtual cpu implementation so
it may not help in mainline but anyway :)

	-- Cyrill
---
 net/core/pktgen.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/net/core/pktgen.c
=====================================================================
--- linux-2.6.git.orig/net/core/pktgen.c
+++ linux-2.6.git/net/core/pktgen.c
@@ -3511,7 +3511,7 @@ static int pktgen_thread_worker(void *ar
 	struct pktgen_dev *pkt_dev = NULL;
 	int cpu = t->cpu;
 
-	BUG_ON(smp_processor_id() != cpu);
+	BUG_ON(task_cpu(current) != cpu);
 
 	init_waitqueue_head(&t->queue);
 	complete(&t->start_done);
