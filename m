From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] bonding: restrict the data protected by rcu_read_lock
Date: Tue, 12 Jul 2016 15:28:17 +0800
Message-ID: <1468308497-5384-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.221.41.8] ([221.221.41.8]:55183 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750974AbcGLHfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 03:35:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this function, origin is a pointer to struct aggregator.
No matter what agg is changed to, it has nothing to do with origin.

CC: Jay Vosburgh <jay.vosburgh@canonical.com>
Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/bonding/bond_3ad.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index edc70ff..20afee3 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1624,8 +1624,8 @@ static void ad_agg_selection_logic(struct aggregator *agg,
 	struct slave *slave;
 	struct port *port;
 
-	rcu_read_lock();
 	origin = agg;
+	rcu_read_lock();
 	active = __get_active_agg(agg);
 	best = (active && agg_device_up(active)) ? active : NULL;
 
-- 
1.7.9.5
