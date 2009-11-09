From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_mirred: don't go back.
Date: Mon, 09 Nov 2009 14:43:00 +0800
Message-ID: <4AF7B9F4.6010507@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	xiaosuo <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:62197 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbZKIGuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 01:50:16 -0500
Received: by pzk26 with SMTP id 26so1919783pzk.4
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2009 22:50:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

don't go back.

don't go back.
----
net/sched/act_mirred.c | 24 +++++++++++++-----------
1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index b9aaab4..e1d8e2c 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -160,17 +160,7 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 		if (net_ratelimit())
 			printk("mirred to Houston: device %s is gone!\n",
 			       dev->name);
-bad_mirred:
-		if (skb2 != NULL)
-			kfree_skb(skb2);
-		m->tcf_qstats.overlimits++;
-		m->tcf_bstats.bytes += qdisc_pkt_len(skb);
-		m->tcf_bstats.packets++;
-		spin_unlock(&m->tcf_lock);
-		/* should we be asking for packet to be dropped?
-		 * may make sense for redirect case only
-		*/
-		return TC_ACT_SHOT;
+		goto bad_mirred;
 	}
 
 	skb2 = skb_act_clone(skb, GFP_ATOMIC);
@@ -199,6 +189,18 @@ bad_mirred:
 	dev_queue_xmit(skb2);
 	spin_unlock(&m->tcf_lock);
 	return m->tcf_action;
+
+bad_mirred:
+	if (skb2 != NULL)
+		kfree_skb(skb2);
+	m->tcf_qstats.overlimits++;
+	m->tcf_bstats.bytes += qdisc_pkt_len(skb);
+	m->tcf_bstats.packets++;
+	spin_unlock(&m->tcf_lock);
+	/* should we be asking for packet to be dropped?
+	 * may make sense for redirect case only
+	 */
+	return TC_ACT_SHOT;
 }
 
 static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)


