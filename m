From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 2/2] tipc: make the code look more readability
Date: Tue, 17 Dec 2013 15:03:47 +0800
Message-ID: <1387263827-20876-3-git-send-email-wangweidong1@huawei.com>
References: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:30683 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab3LQHF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:05:59 -0500
In-Reply-To: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make the code look more readability than commit 3b8401fe9dba does.
This patch is cosmetic and does not change the operation of TIPC
in any way.

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/socket.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 83f466e..5efdeef 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -751,13 +751,10 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 
 	/* Handle special cases where there is no connection */
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		res = -ENOTCONN;
-
 		if (sock->state == SS_UNCONNECTED)
 			res = send_packet(NULL, sock, m, total_len);
-		else if (sock->state == SS_DISCONNECTING)
-			res = -EPIPE;
-
+		else
+			res = sock->state == SS_DISCONNECTING ? -EPIPE : -ENOTCONN;
 		goto exit;
 	}
 
-- 
1.7.12
