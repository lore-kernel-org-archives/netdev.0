From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] bridge: use list_for_each_entry_continue_reverse
Date: Wed, 18 Jun 2014 16:07:16 +0800
Message-ID: <1403078836-14660-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:60575 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbaFRIHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 04:07:07 -0400
Received: by mail-pb0-f52.google.com with SMTP id rq2so492305pbb.11
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 01:07:06 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id tg9sm2023999pbc.29.2014.06.18.01.07.04
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 01:07:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

use list_for_each_entry_continue_reverse to rollback in fdb_add_hw
when add address failed

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/bridge/br_fdb.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b524c36..7be3366 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -93,7 +93,7 @@ static void fdb_rcu_free(struct rcu_head *head)
 static void fdb_add_hw(struct net_bridge *br, const unsigned char *addr)
 {
 	int err;
-	struct net_bridge_port *p, *tmp;
+	struct net_bridge_port *p;
 
 	ASSERT_RTNL();
 
@@ -107,11 +107,9 @@ static void fdb_add_hw(struct net_bridge *br, const unsigned char *addr)
 
 	return;
 undo:
-	list_for_each_entry(tmp, &br->port_list, list) {
-		if (tmp == p)
-			break;
-		if (!br_promisc_port(tmp))
-			dev_uc_del(tmp->dev, addr);
+	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
+		if (!br_promisc_port(p))
+			dev_uc_del(p->dev, addr);
 	}
 }
 
-- 
1.7.10.4
