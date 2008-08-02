From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 02 Aug 2008 12:22:51 -0700 (PDT)
Message-ID: <20080802.122251.94384264.davem@davemloft.net>
References: <20080802133719.GB2970@ami.dom.local>
	<20080802162733.GA10059@ami.dom.local>
	<20080802.121815.167998262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754097AbYHBTWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 15:22:51 -0400
In-Reply-To: <20080802.121815.167998262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 02 Aug 2008 12:18:15 -0700 (PDT)

> See my other emails, it isn't even necessary anyways.

Sorry, because some idiot took part of the conversation private
my follow-on fixup patch didn't make it to the list, here it is.

It goes on top of the original patch I sent out:

diff --git a/net/core/dev.c b/net/core/dev.c
index 69320a5..da7acac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1796,7 +1796,7 @@ gso:
 	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
 	if (q->enqueue) {
-		spinlock_t *root_lock = qdisc_root_lock(q);
+		spinlock_t *root_lock = qdisc_lock(q);
 
 		spin_lock(root_lock);
 
@@ -1995,7 +1995,7 @@ static void net_tx_action(struct softirq_action *h)
 			smp_mb__before_clear_bit();
 			clear_bit(__QDISC_STATE_SCHED, &q->state);
 
-			root_lock = qdisc_root_lock(q);
+			root_lock = qdisc_lock(q);
 			if (spin_trylock(root_lock)) {
 				qdisc_run(q);
 				spin_unlock(root_lock);
