From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net] net/sched: act_pedit: limit negative offset
Date: Sun, 27 Nov 2016 17:58:15 +0200
Message-ID: <20161127155815.10359-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36589 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752362AbcK0P61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:58:27 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so15081067wma.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 07:58:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should not allow setting a negative offset that goes below the skb head.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
Hi Dave,

Please pull to -stable branches.

Thanks,
Amir

 net/sched/act_pedit.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index b54d56d4959b..e79e8a88f2d2 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -154,8 +154,11 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 			}
 
 			ptr = skb_header_pointer(skb, off + offset, 4, &_data);
-			if (!ptr)
+			if ((unsigned char *)ptr < skb->head) {
+				pr_info("tc filter pedit offset out of bounds\n");
 				goto bad;
+			}
+
 			/* just do it, baby */
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
 			if (ptr == &_data)
-- 
2.10.2
