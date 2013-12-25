From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 1/2] tipc: make the code look more better
Date: Wed, 25 Dec 2013 10:11:12 +0800
Message-ID: <1387937473-5804-2-git-send-email-wangweidong1@huawei.com>
References: <1387937473-5804-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: <jeremy.kalman@windriver.com>, <jon.maloy@ericsson.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:9585 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab3LYCLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 21:11:40 -0500
In-Reply-To: <1387937473-5804-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 0cee6bbe06f ("tipc: remove unnecessary variables and conditions")
didn't make the code look best. So fix it. This patch is cosmetic
and does not change the operation of TIPC in any way.

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
