From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 11/11] act_police: remove <=mtu check for gso skbs
Date: Fri,  8 Feb 2013 19:59:41 +0100
Message-ID: <1360349981-27801-12-git-send-email-jiri@resnulli.us>
References: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:47625 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946882Ab3BHTAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:00:21 -0500
Received: by mail-ea0-f181.google.com with SMTP id i13so1787216eaa.26
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 11:00:20 -0800 (PST)
In-Reply-To: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check made bigger packets incorrectly dropped. Remove this
limitation for gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_police.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 8723183..2a55cea 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -311,7 +311,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 		return police->tcf_action;
 	}
 
-	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
+	if (qdisc_pkt_len(skb) <= police->tcfp_mtu || skb_is_gso(skb)) {
 		if (!police->rate_present) {
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
-- 
1.8.1.2
