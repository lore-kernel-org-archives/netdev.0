From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 5/6] tipc: change lock_sock order in connect()
Date: Fri, 6 Dec 2013 14:23:41 +0800
Message-ID: <1386311022-11176-6-git-send-email-wangweidong1@huawei.com>
References: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:36440 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756148Ab3LFGX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:23:59 -0500
In-Reply-To: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when res<=0, return the res no need to add lock_sock. so remove it.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 844bf34..83f466e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1507,14 +1507,12 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 				sock->state != SS_CONNECTING,
 				timeout ? (long)msecs_to_jiffies(timeout)
 					: MAX_SCHEDULE_TIMEOUT);
-		lock_sock(sk);
 		if (res <= 0) {
 			if (res == 0)
 				res = -ETIMEDOUT;
-			else
-				; /* leave "res" unchanged */
-			goto exit;
+			return res;
 		}
+		lock_sock(sk);
 	}
 
 	if (unlikely(sock->state == SS_DISCONNECTING))
-- 
1.7.12
