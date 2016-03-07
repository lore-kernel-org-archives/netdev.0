From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 02/13] net: Make sock_alloc exportable
Date: Mon, 7 Mar 2016 14:11:01 -0800
Message-ID: <1457388672-2600559-3-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:17563 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753616AbcCGWLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:11:52 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27MABQj022008
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:11:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hh470ayx-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:11:51 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 97674c00e4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:11:50 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export it for cases where we want to create sockets by hand.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/net.h | 1 +
 net/socket.c        | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 0b4ac7d..49175e4 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -215,6 +215,7 @@ int __sock_create(struct net *net, int family, int type, int proto,
 int sock_create(int family, int type, int proto, struct socket **res);
 int sock_create_kern(struct net *net, int family, int type, int proto, struct socket **res);
 int sock_create_lite(int family, int type, int proto, struct socket **res);
+struct socket *sock_alloc(void);
 void sock_release(struct socket *sock);
 int sock_sendmsg(struct socket *sock, struct msghdr *msg);
 int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
diff --git a/net/socket.c b/net/socket.c
index c044d1e..38a78d4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -533,7 +533,7 @@ static const struct inode_operations sockfs_inode_ops = {
  *	NULL is returned.
  */
 
-static struct socket *sock_alloc(void)
+struct socket *sock_alloc(void)
 {
 	struct inode *inode;
 	struct socket *sock;
@@ -554,6 +554,7 @@ static struct socket *sock_alloc(void)
 	this_cpu_add(sockets_in_use, 1);
 	return sock;
 }
+EXPORT_SYMBOL(sock_alloc);
 
 /**
  *	sock_release	-	close a socket
-- 
2.6.5
