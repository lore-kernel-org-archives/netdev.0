From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem: fix loss
Date: Fri, 28 Apr 2006 10:22:40 -0700
Message-ID: <20060428102240.59ba2a7a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, George Nychis <gnychis@cmu.edu>,
	netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45987 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030460AbWD1RXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 13:23:12 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following one line fix is needed to make loss function of
netem work right when doing loss on the local host.
Otherwise, higher layers just recover.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/net/sched/sch_netem.c
+++ linux-2.6/net/sched/sch_netem.c
@@ -167,7 +167,7 @@ static int netem_enqueue(struct sk_buff 
 	if (count == 0) {
 		sch->qstats.drops++;
 		kfree_skb(skb);
-		return NET_XMIT_DROP;
+		return NET_XMIT_BYPASS;
 	}
 
 	/*
