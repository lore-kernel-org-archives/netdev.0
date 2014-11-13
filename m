From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH 54/56] net/ipv4: support compiling out splice
Date: Thu, 13 Nov 2014 22:23:31 +0100
Message-ID: <1415913813-362-55-git-send-email-pieter@boesman.nl>
References: <pieter@boesman.nl>
 <1415913813-362-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh@joshtriplett.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org (open list:NETWORKING [IPv4/...),
	linux-kernel@vger.kernel.org (open list)
To: pieter@boesman.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34884 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934688AbaKMVbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 16:31:45 -0500
In-Reply-To: <1415913813-362-1-git-send-email-pieter@boesman.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile out splice support from ipv4 networking when the splice-family of
syscalls is not supported by the system (i.e. CONFIG_SYSCALL_SPLICE is
undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 net/ipv4/af_inet.c | 2 +-
 net/ipv4/tcp.c     | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d156b3c..e025478 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -917,7 +917,7 @@ const struct proto_ops inet_stream_ops = {
 	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
-	.splice_read	   = tcp_splice_read,
+	SPLICE_READ_INIT(tcp_splice_read)
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 541f26a..afc825f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -686,6 +686,7 @@ static void tcp_push(struct sock *sk, int flags, int mss_now,
 	__tcp_push_pending_frames(sk, mss_now, nonagle);
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 static int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 				unsigned int offset, size_t len)
 {
@@ -805,6 +806,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 	return ret;
 }
 EXPORT_SYMBOL(tcp_splice_read);
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 {
-- 
1.9.1
