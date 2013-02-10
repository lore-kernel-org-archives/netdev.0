From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 11/11] act_police: remove <=mtu check for gso skbs
Date: Sun, 10 Feb 2013 11:52:19 +0100
Message-ID: <1360493539-14868-12-git-send-email-jiri@resnulli.us>
References: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:52918 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310Ab3BJKxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:53:08 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so2674814eek.4
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 02:53:07 -0800 (PST)
In-Reply-To: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check made bigger packets incorrectly dropped. Remove this
limitation for gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_police.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 71bf4f5..e11eca9 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -325,7 +325,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 		return police->tcf_action;
 	}
 
-	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
+	if (qdisc_pkt_len(skb) <= police->tcfp_mtu || skb_is_gso(skb)) {
 		if (!police->rate_present) {
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
-- 
1.8.1.2
