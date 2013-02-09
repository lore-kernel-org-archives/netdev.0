From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 11/11] act_police: remove <=mtu check for gso skbs
Date: Sat,  9 Feb 2013 17:45:12 +0100
Message-ID: <1360428312-1277-12-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:35943 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932461Ab3BIQps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:48 -0500
Received: by mail-ea0-f182.google.com with SMTP id a12so2064510eaa.27
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:46 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check made bigger packets incorrectly dropped. Remove this
limitation for gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_police.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 3821508..e6f480b 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -322,7 +322,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 		return police->tcf_action;
 	}
 
-	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
+	if (qdisc_pkt_len(skb) <= police->tcfp_mtu || skb_is_gso(skb)) {
 		if (!police->rate_present) {
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
-- 
1.8.1.2
