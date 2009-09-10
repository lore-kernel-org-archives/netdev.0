From: Jens Rosenboom <me@jayr.de>
Subject: Re: [RFC] net/core: Delay neighbor only if it has been used after
 confirmed
Date: Thu, 10 Sep 2009 18:21:47 +0200
Message-ID: <1252599707.5980.13.camel@fnki-nb00130>
References: <1251883079.5813.18.camel@fnki-nb00130>
	 <4A9E639B.20907@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:60138 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbZIJQVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 12:21:52 -0400
In-Reply-To: <4A9E639B.20907@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-02 at 21:22 +0900, YOSHIFUJI Hideaki wrote:
[...]
> And, this "if" for REACHABLE->DELAY may be completely needless.
> Timer in REACHABLE is only for state transition for toward REACHABLE
> or STALE.

I did some testing with the following patch, which works fine for me, so
I propose this one now instead of my previous one. I still have no real
idea about the non-IPv6 implications of this, though.

---

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e587e68..f61926f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -819,13 +819,6 @@ static void neigh_timer_handler(unsigned long arg)
 				   neigh->confirmed + neigh->parms->reachable_time)) {
 			NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
 			next = neigh->confirmed + neigh->parms->reachable_time;
-		} else if (time_before_eq(now,
-					  neigh->used + neigh->parms->delay_probe_time)) {
-			NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
-			neigh->nud_state = NUD_DELAY;
-			neigh->updated = jiffies;
-			neigh_suspect(neigh);
-			next = now + neigh->parms->delay_probe_time;
 		} else {
 			NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
 			neigh->nud_state = NUD_STALE;


