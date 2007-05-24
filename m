From: Patrick McHardy <kaber@trash.net>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Thu, 24 May 2007 07:41:00 +0200
Message-ID: <4655256C.1030208@trash.net>
References: <46541DC4.4090501@trash.net>	<20070523112559.GA24604@gondor.apana.org.au>	<20070523114021.GA21880@elte.hu> <20070523.143056.115914753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030401070708020603050103"
Cc: mingo@elte.hu, herbert@gondor.apana.org.au, kernel@prachanda.info,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, tglx@linutronix.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57870 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757533AbXEXFoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 01:44:19 -0400
In-Reply-To: <20070523.143056.115914753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030401070708020603050103
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
>>* Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>
>>>[NET_SCHED]: Fix qdisc_restart return value when dequeue is empty
>
> Applied, thanks everyone.


Even though it didn't fix this problem, this patch I sent earlier is
also needed.


--------------030401070708020603050103
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: sch_htb: fix event cache time calculation

The event cache time must be an absolute value, when no event exists it is
incorrectly set to 1s instead of 1s in the future.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 49d1023ea0ea8377e740123d5954e88a00f78b7c
tree 031c210f1b5e37ade5a4fa519f5808cd49225b89
parent 637fc540b0ad22bf7971929e906e704236af06cd
author Patrick McHardy <kaber@trash.net> Mon, 21 May 2007 23:24:16 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 21 May 2007 23:25:51 +0200

 net/sched/sch_htb.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 99bcec8..035788c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -976,8 +976,9 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 
 		if (q->now >= q->near_ev_cache[level]) {
 			event = htb_do_events(q, level);
-			q->near_ev_cache[level] = event ? event :
-							  PSCHED_TICKS_PER_SEC;
+			if (!event)
+				event = q->now + PSCHED_TICKS_PER_SEC;
+			q->near_ev_cache[level] = event;
 		} else
 			event = q->near_ev_cache[level];
 

--------------030401070708020603050103--
