From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 3/6] tipc: use a same goto path
Date: Fri, 6 Dec 2013 14:23:39 +0800
Message-ID: <1386311022-11176-4-git-send-email-wangweidong1@huawei.com>
References: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:4806 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab3LFGX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:23:57 -0500
In-Reply-To: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will goto exit on every pach. so use one goto.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/socket.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 32037c5..844bf34 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -751,16 +751,14 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 
 	/* Handle special cases where there is no connection */
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		if (sock->state == SS_UNCONNECTED) {
+		res = -ENOTCONN;
+
+		if (sock->state == SS_UNCONNECTED)
 			res = send_packet(NULL, sock, m, total_len);
-			goto exit;
-		} else if (sock->state == SS_DISCONNECTING) {
+		else if (sock->state == SS_DISCONNECTING)
 			res = -EPIPE;
-			goto exit;
-		} else {
-			res = -ENOTCONN;
-			goto exit;
-		}
+
+		goto exit;
 	}
 
 	if (unlikely(m->msg_name)) {
-- 
1.7.12
