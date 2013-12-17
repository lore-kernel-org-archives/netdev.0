From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 1/2] tipc: make the code look more better
Date: Tue, 17 Dec 2013 15:03:46 +0800
Message-ID: <1387263827-20876-2-git-send-email-wangweidong1@huawei.com>
References: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2833 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3LQHEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:04:33 -0500
In-Reply-To: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make the code look more better than commit 0cee6bbe06f does.
This patch is cosmetic and does not change the operation of
TIPC in any way.

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/port.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5fd4c8c..ee81be0 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -832,14 +832,13 @@ exit:
  */
 int __tipc_disconnect(struct tipc_port *tp_ptr)
 {
-	if (tp_ptr->connected) {
-		tp_ptr->connected = 0;
-		/* let timer expire on it's own to avoid deadlock! */
-		tipc_nodesub_unsubscribe(&tp_ptr->subscription);
-		return 0;
-	}
+	if (!tp_ptr->connected)
+		return -ENOTCONN;
 
-	return -ENOTCONN;
+	tp_ptr->connected = 0;
+	/* let timer expire on it's own to avoid deadlock! */
+	tipc_nodesub_unsubscribe(&tp_ptr->subscription);
+	return 0;
 }
 
 /*
-- 
1.7.12
