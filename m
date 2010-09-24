From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 1/5] AF_UNIX: add getsockopt and setsockopt on stream sockets
Date: Fri, 24 Sep 2010 18:25:12 +0100
Message-ID: <1285349116-17529-1-git-send-email-alban.crequy@collabora.co.uk>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbus@freedesktop.org, Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:39586 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab0IXRfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 13:35:21 -0400
In-Reply-To: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fef2cc5..47d9f77 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -492,6 +492,10 @@ static unsigned int unix_dgram_poll(struct file *, struct socket *,
 				    poll_table *);
 static int unix_ioctl(struct socket *, unsigned int, unsigned long);
 static int unix_shutdown(struct socket *, int);
+static int unix_stream_setsockopt(struct socket *, int, int,
+				  char __user *, unsigned int);
+static int unix_stream_getsockopt(struct socket *, int, int,
+				  char __user *, int __user *);
 static int unix_stream_sendmsg(struct kiocb *, struct socket *,
 			       struct msghdr *, size_t);
 static int unix_stream_recvmsg(struct kiocb *, struct socket *,
@@ -518,8 +522,8 @@ static const struct proto_ops unix_stream_ops = {
 	.ioctl =	unix_ioctl,
 	.listen =	unix_listen,
 	.shutdown =	unix_shutdown,
-	.setsockopt =	sock_no_setsockopt,
-	.getsockopt =	sock_no_getsockopt,
+	.setsockopt =	unix_stream_setsockopt,
+	.getsockopt =	unix_stream_getsockopt,
 	.sendmsg =	unix_stream_sendmsg,
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
@@ -1494,6 +1498,19 @@ out:
 }
 
 
+static int unix_stream_setsockopt(struct socket *sock, int level, int optname,
+				  char __user *optval, unsigned int optlen)
+{
+	return -EOPNOTSUPP;
+}
+
+int unix_stream_getsockopt(struct socket *sock, int level, int optname,
+			   char __user *optval, int __user *optlen)
+{
+	return -EOPNOTSUPP;
+}
+
+
 static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
 {
-- 
1.7.1

