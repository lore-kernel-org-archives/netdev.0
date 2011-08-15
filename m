From: jamal <hadi@cyberus.ca>
Subject: [PATCH] net_sched: fix port mirror/redirect stats reporting
Date: Mon, 15 Aug 2011 11:25:40 -0400
Message-ID: <1313421940.1798.2.camel@mojatatu>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:41093 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489Ab1HOPZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 11:25:50 -0400
Received: by ewy4 with SMTP id 4so1866564ewy.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 08:25:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6a51508a01671114c236602d071d4bff53422c60
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Mon Aug 15 11:17:06 2011 -0400

    [PATCH] net_sched: fix port mirror/redirect stats reporting
    
    When a redirected or mirrored packet is dropped by the target
    device we need to record statistics.
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 961386e..d5ef6ec 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -196,8 +196,7 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
-	dev_queue_xmit(skb2);
-	err = 0;
+	err = dev_queue_xmit(skb2);
 
 out:
 	if (err) {


