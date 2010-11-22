From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 2/9] AF_UNIX: add setsockopt on Unix sockets
Date: Mon, 22 Nov 2010 18:36:15 +0000
Message-ID: <1290450982-17480-2-git-send-email-alban.crequy@collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7ff31c6..6eca106 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -512,6 +512,8 @@ static unsigned int unix_dgram_poll(struct file *, struct socket *,
 				    poll_table *);
 static int unix_ioctl(struct socket *, unsigned int, unsigned long);
 static int unix_shutdown(struct socket *, int);
+static int unix_setsockopt(struct socket *, int, int,
+			   char __user *, unsigned int);
 static int unix_stream_sendmsg(struct kiocb *, struct socket *,
 			       struct msghdr *, size_t);
 static int unix_stream_recvmsg(struct kiocb *, struct socket *,
@@ -538,7 +540,7 @@ static const struct proto_ops unix_stream_ops = {
 	.ioctl =	unix_ioctl,
 	.listen =	unix_listen,
 	.shutdown =	unix_shutdown,
-	.setsockopt =	sock_no_setsockopt,
+	.setsockopt =	unix_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_stream_sendmsg,
 	.recvmsg =	unix_stream_recvmsg,
@@ -559,7 +561,7 @@ static const struct proto_ops unix_dgram_ops = {
 	.ioctl =	unix_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	unix_shutdown,
-	.setsockopt =	sock_no_setsockopt,
+	.setsockopt =	unix_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_dgram_sendmsg,
 	.recvmsg =	unix_dgram_recvmsg,
@@ -580,7 +582,7 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.ioctl =	unix_ioctl,
 	.listen =	unix_listen,
 	.shutdown =	unix_shutdown,
-	.setsockopt =	sock_no_setsockopt,
+	.setsockopt =	unix_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_seqpacket_sendmsg,
 	.recvmsg =	unix_dgram_recvmsg,
@@ -1533,6 +1535,13 @@ out:
 }
 
 
+static int unix_setsockopt(struct socket *sock, int level, int optname,
+			   char __user *optval, unsigned int optlen)
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
