From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: fix accept4() flags not work
Date: Sun,  8 Jan 2017 18:47:30 +0800
Message-ID: <1483872450-2706-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:36228 "EHLO m50-134.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750879AbdAHKrs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:47:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

user input flags store to newsock which should be used.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index a8c2307..415f988 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1508,7 +1508,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	if (err)
 		goto out_fd;
 
-	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
+	err = sock->ops->accept(sock, newsock, newsock->file->f_flags);
 	if (err < 0)
 		goto out_fd;
 
-- 
2.7.4
