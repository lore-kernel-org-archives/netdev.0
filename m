From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] net: sched: cls_basic: fix error path in basic_change()
Date: Fri,  5 Dec 2014 15:50:22 +0100
Message-ID: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:35248 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaLEOu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:50:26 -0500
Received: by mail-wg0-f52.google.com with SMTP id a1so1081513wgh.25
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 06:50:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_basic.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 7cf0a62..5aed341 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -178,10 +178,9 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 			return -EINVAL;
 	}
 
-	err = -ENOBUFS;
 	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
-	if (fnew == NULL)
-		goto errout;
+	if (!fnew)
+		return -ENOBUFS;
 
 	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 	err = -EINVAL;
-- 
1.9.3
