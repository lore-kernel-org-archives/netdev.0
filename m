From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 3/8] af_unix: add setsockopt on unix sockets
Date: Fri, 21 Jan 2011 14:39:43 +0000
Message-ID: <1295620788-6002-3-git-send-email-alban.crequy@collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unix_setsockopt() is called only on SOCK_DGRAM and SOCK_SEQPACKET unix sockets

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d8d98d5..7ea85de 100644
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
@@ -1561,6 +1563,13 @@ out:
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
1.7.2.3
