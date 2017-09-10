From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH] net/sched: fix pointer check in gen_handle
Date: Sun, 10 Sep 2017 15:48:50 -0400
Message-ID: <1505072930-13049-1-git-send-email-johunt@akamai.com>
Cc: netdev@vger.kernel.org, Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00190b01.pphosted.com ([67.231.149.131]:58014 "EHLO
        mx0a-00190b01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750789AbdIJTtK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 15:49:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes sparse warning about pointer in gen_handle:
net/sched/cls_rsvp.h:392:40: warning: Using plain integer as NULL pointer

Fixes: 8113c095672f6 ("net_sched: use void pointer for filter handle")
Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/sched/cls_rsvp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 98c05db85bcb..b1f6ed48bc72 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -389,7 +389,7 @@ static unsigned int gen_handle(struct tcf_proto *tp, unsigned salt)
 		if ((data->hgenerator += 0x10000) == 0)
 			data->hgenerator = 0x10000;
 		h = data->hgenerator|salt;
-		if (rsvp_get(tp, h) == 0)
+		if (!rsvp_get(tp, h))
 			return h;
 	}
 	return 0;
-- 
1.9.1
