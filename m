From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: cls_flower: fix ndo_setup_tc type for stats call
Date: Wed, 16 Aug 2017 17:15:18 +0200
Message-ID: <20170816151518.4554-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35732 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdHPPPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:15:22 -0400
Received: by mail-wr0-f195.google.com with SMTP id w63so3601894wrc.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:15:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

I made a stupid mistake using TC_CLSFLOWER_STATS instead of
TC_SETUP_CLSFLOWER. Funny thing is that both are defined as "2" so it
actually did not cause any harm. Anyway, fixing it now.

Fixes: 2572ac53c46f ("net: sched: make type an argument for ndo_setup_tc")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 052e902..bd9dab4 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -289,7 +289,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_CLSFLOWER_STATS,
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
 				      &cls_flower);
 }
 
-- 
2.9.3
