From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] act_mirred: clear sender cpu before sending to tx
Date: Tue,  6 Oct 2015 17:23:47 -0700
Message-ID: <1444177427-5603-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35761 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbbJGAYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 20:24:13 -0400
Received: by pacfv12 with SMTP id fv12so2209005pac.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 17:24:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
the skb->sender_cpu needs to be cleared when moving from Rx
Tx, otherwise kernel could crash.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 2efaf4e..32fcdec 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -179,6 +179,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
+	skb_sender_cpu_clear(skb2);
 	err = dev_queue_xmit(skb2);
 
 	if (err) {
-- 
1.8.3.1
