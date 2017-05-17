From: David Miller <davem@davemloft.net>
Subject: [PATCH] sch_dsmark: Fix uninitialized variable warning.
Date: Wed, 17 May 2017 16:05:33 -0400 (EDT)
Message-ID: <20170517.160533.910802621092127012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752968AbdEQUFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 16:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We still need to initialize err to -EINVAL for
the case where 'opt' is NULL in dsmark_init().

Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_dsmark.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index ba45102..7ccdd82 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -333,7 +333,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct nlattr *tb[TCA_DSMARK_MAX + 1];
-	int err;
+	int err = -EINVAL;
 	u32 default_index = NO_DEFAULT_INDEX;
 	u16 indices;
 	int i;
-- 
2.7.4
