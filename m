From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv6 net-next 13/15] net: act_mirred: allow statistic updates from offloaded actions
Date: Sun, 18 Sep 2016 16:09:23 +0100
Message-ID: <1474211365-20088-14-git-send-email-jakub.kicinski@netronome.com>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35857 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754606AbcIRPJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:09:59 -0400
Received: by mail-wm0-f41.google.com with SMTP id w84so37327669wmg.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 08:09:58 -0700 (PDT)
In-Reply-To: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement .stats_update() callback.  The implementation
is generic and can be reused by other simple actions if
needed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/sched/act_mirred.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6038c85d92f5..f9862d89cb93 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -204,6 +204,13 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	return retval;
 }
 
+static void tcf_stats_update(struct tc_action *a, u64 bytes, u32 packets,
+			     u64 lastuse)
+{
+	tcf_lastuse_update(&a->tcfa_tm);
+	_bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets);
+}
+
 static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
@@ -280,6 +287,7 @@ static struct tc_action_ops act_mirred_ops = {
 	.type		=	TCA_ACT_MIRRED,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_mirred,
+	.stats_update	=	tcf_stats_update,
 	.dump		=	tcf_mirred_dump,
 	.cleanup	=	tcf_mirred_release,
 	.init		=	tcf_mirred_init,
-- 
1.9.1
