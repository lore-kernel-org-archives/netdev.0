From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] socket: use iov_length()
Date: Wed, 14 Jan 2015 11:07:50 +0100
Message-ID: <1421230070-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:47594 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbbANKIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 05:08:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better to use available helpers.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/socket.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index a2c33a4dc7ba..b1f3fa4da020 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -883,10 +883,8 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 {
 	struct socket *sock = file->private_data;
 	size_t size = 0;
-	int i;
 
-	for (i = 0; i < nr_segs; i++)
-		size += iov[i].iov_len;
+	size = iov_length(iov, nr_segs);
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
@@ -922,10 +920,8 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 {
 	struct socket *sock = file->private_data;
 	size_t size = 0;
-	int i;
 
-	for (i = 0; i < nr_segs; i++)
-		size += iov[i].iov_len;
+	size = iov_length(iov, nr_segs);
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
-- 
2.1.0
