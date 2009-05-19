From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: gen_estimator: Fix signed integers right-shifts.
Date: Tue, 19 May 2009 21:09:15 +0200
Message-ID: <20090519190915.GC2981@ami.dom.local>
References: <20090516141430.GB3013@ami.dom.local> <4A118F98.60101@cosmosbay.com> <20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net> <4A11F67B.3050805@cosmosbay.com> <20090519070252.GA4210@ff.dom.local> <4A126058.7030605@cosmosbay.com> <20090519074247.GB4210@ff.dom.local> <20090519075715.GC4210@ff.dom.local> <4A12F46C.4070605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vexwek@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, devik@cdi.cz
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:45454 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbZESTLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:11:24 -0400
Received: by bwz22 with SMTP id 22so4025064bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 12:11:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A12F46C.4070605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 08:03:24PM +0200, Eric Dumazet wrote:
...
> As I said earlier, I found your concern right, so please submit a patch ?

OK, thanks,
Jarek P.
----------------->
pkt_sched: gen_estimator: Fix signed integers right-shifts.

Right-shifts of signed integers are implementation-defined so unportable.

With feedback from: Eric Dumazet <dada1@cosmosbay.com>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/net/core/gen_estimator.c b/net/core/gen_estimator.c
--- a/net/core/gen_estimator.c	2009-05-19 20:33:47.000000000 +0200
+++ b/net/core/gen_estimator.c	2009-05-19 20:40:58.000000000 +0200
@@ -128,12 +128,12 @@ static void est_timer(unsigned long arg)
 		npackets = e->bstats->packets;
 		brate = (nbytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes = nbytes;
-		e->avbps += ((s64)(brate - e->avbps)) >> e->ewma_log;
+		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
 		e->rate_est->bps = (e->avbps+0xF)>>5;
 
 		rate = (npackets - e->last_packets)<<(12 - idx);
 		e->last_packets = npackets;
-		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
+		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
 skip:
 		read_unlock(&est_lock);
