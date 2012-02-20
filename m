From: Javier Martinez Canillas <javier@collabora.co.uk>
Subject: [PATCH 03/10] af_unix: add setsockopt on unix sockets
Date: Mon, 20 Feb 2012 16:57:28 +0100
Message-ID: <1329753455-1106-4-git-send-email-javier@collabora.co.uk>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

unix_setsockopt() is called only on SOCK_DGRAM and SOCK_SEQPACKET unix sockets

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 85d3bb7..3537f20 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -515,6 +515,8 @@ static unsigned int unix_dgram_poll(struct file *, struct socket *,
 				    poll_table *);
 static int unix_ioctl(struct socket *, unsigned int, unsigned long);
 static int unix_shutdown(struct socket *, int);
+static int unix_setsockopt(struct socket *, int, int,
+			   char __user *, unsigned int);
 static int unix_stream_sendmsg(struct kiocb *, struct socket *,
 			       struct msghdr *, size_t);
 static int unix_stream_recvmsg(struct kiocb *, struct socket *,
@@ -564,7 +566,7 @@ static const struct proto_ops unix_dgram_ops = {
 	.ioctl =	unix_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	unix_shutdown,
-	.setsockopt =	sock_no_setsockopt,
+	.setsockopt =	unix_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_dgram_sendmsg,
 	.recvmsg =	unix_dgram_recvmsg,
@@ -585,7 +587,7 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.ioctl =	unix_ioctl,
 	.listen =	unix_listen,
 	.shutdown =	unix_shutdown,
-	.setsockopt =	sock_no_setsockopt,
+	.setsockopt =	unix_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_seqpacket_sendmsg,
 	.recvmsg =	unix_seqpacket_recvmsg,
@@ -1583,6 +1585,13 @@ out:
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
1.7.7.6
