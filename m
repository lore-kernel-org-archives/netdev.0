From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2] socket: use iov_length()
Date: Thu, 15 Jan 2015 10:35:58 +0100
Message-ID: <1421314558-4252-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20150114.164528.230093054757243054.davem@davemloft.net>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48831 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbAOJgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 04:36:04 -0500
In-Reply-To: <20150114.164528.230093054757243054.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better to use available helpers.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: initialize size variable with iov_length() result

 net/socket.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index a2c33a4dc7ba..e1278d7e1d5d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -882,11 +882,7 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 		unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
-	size_t size = 0;
-	int i;
-
-	for (i = 0; i < nr_segs; i++)
-		size += iov[i].iov_len;
+	size_t size = iov_length(iov, nr_segs);
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
@@ -921,11 +917,7 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 			unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
-	size_t size = 0;
-	int i;
-
-	for (i = 0; i < nr_segs; i++)
-		size += iov[i].iov_len;
+	size_t size = iov_length(iov, nr_segs);
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
-- 
2.1.0
