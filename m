From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_mirred: combine duplicate code
Date: Wed, 30 Jun 2010 16:54:58 +0800
Message-ID: <1277888098-27632-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:62896 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab0F3I5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 04:57:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_mirred: combine duplicate code

tcf_bstats is updated in any way, so we can do it earlier to reduce the size of
the code.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_mirred.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 2e9a7b9..a16b017 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -160,6 +160,8 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 
 	spin_lock(&m->tcf_lock);
 	m->tcf_tm.lastuse = jiffies;
+	m->tcf_bstats.bytes += qdisc_pkt_len(skb);
+	m->tcf_bstats.packets++;
 
 	dev = m->tcfm_dev;
 	if (!(dev->flags & IFF_UP)) {
@@ -174,8 +176,6 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 	if (skb2 == NULL)
 		goto out;
 
-	m->tcf_bstats.bytes += qdisc_pkt_len(skb2);
-	m->tcf_bstats.packets++;
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
 			skb_push(skb2, skb2->dev->hard_header_len);
@@ -193,8 +193,6 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 out:
 	if (err) {
 		m->tcf_qstats.overlimits++;
-		m->tcf_bstats.bytes += qdisc_pkt_len(skb);
-		m->tcf_bstats.packets++;
 		/* should we be asking for packet to be dropped?
 		 * may make sense for redirect case only
 		 */
