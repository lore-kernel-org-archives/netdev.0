From: Cristian Chilipirea <cristian.chilipirea@gmail.com>
Subject: [PATCH] ipv4: Fixed checkpatch warnings and errors
Date: Tue,  8 May 2012 13:58:24 +0300
Message-ID: <1336474704-9366-1-git-send-email-cristian.chilipirea@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel.baluta@gmail.com,
	Cristian Chilipirea <cristian.chilipirea@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38410 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab2EHK6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 06:58:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed warnings and errors in af_inet.c.

Signed-off-by: Cristian Chilipirea <cristian.chilipirea@gmail.com>
---
 net/ipv4/af_inet.c |   55 +++++++++++++++++++++++++++++----------------------
 1 files changed, 31 insertions(+), 24 deletions(-)
 mode change 100644 => 100755 net/ipv4/af_inet.c

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
old mode 100644
new mode 100644
index 10e3751..19399f9
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -28,7 +28,7 @@
  *					some RPC stuff seems happier.
  *		Niibe Yutaka	:	4.4BSD style write async I/O
  *		Alan Cox,
- *		Tony Gale 	:	Fixed reuse semantics.
+ *		Tony Gale	:	Fixed reuse semantics.
  *		Alan Cox	:	bind() shouldn't abort existing but dead
  *					sockets. Stops FTP netin:.. I hope.
  *		Alan Cox	:	bind() works correctly for RAW sockets.
@@ -90,7 +90,7 @@
 #include <linux/random.h>
 #include <linux/slab.h>
 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include <linux/inet.h>
 #include <linux/igmp.h>
@@ -541,7 +541,7 @@ out:
 }
 EXPORT_SYMBOL(inet_bind);
 
-int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
+int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
 		       int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -895,7 +895,8 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 EXPORT_SYMBOL(inet_ioctl);
 
 #ifdef CONFIG_COMPAT
-static int inet_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+static int inet_compat_ioctl(struct socket *sock, unsigned int cmd,
+		unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	int err = -ENOIOCTLCMD;
@@ -1001,8 +1002,7 @@ static const struct net_proto_family inet_family_ops = {
 /* Upon startup we insert all the elements in inetsw_array[] into
  * the linked list inetsw.
  */
-static struct inet_protosw inetsw_array[] =
-{
+static struct inet_protosw inetsw_array[] = {
 	{
 		.type =       SOCK_STREAM,
 		.protocol =   IPPROTO_TCP,
@@ -1020,25 +1020,25 @@ static struct inet_protosw inetsw_array[] =
 		.ops =        &inet_dgram_ops,
 		.no_check =   UDP_CSUM_DEFAULT,
 		.flags =      INET_PROTOSW_PERMANENT,
-       },
+	},
 
-       {
+	{
 		.type =       SOCK_DGRAM,
 		.protocol =   IPPROTO_ICMP,
 		.prot =       &ping_prot,
 		.ops =        &inet_dgram_ops,
 		.no_check =   UDP_CSUM_DEFAULT,
 		.flags =      INET_PROTOSW_REUSE,
-       },
-
-       {
-	       .type =       SOCK_RAW,
-	       .protocol =   IPPROTO_IP,	/* wild card */
-	       .prot =       &raw_prot,
-	       .ops =        &inet_sockraw_ops,
-	       .no_check =   UDP_CSUM_DEFAULT,
-	       .flags =      INET_PROTOSW_REUSE,
-       }
+	},
+
+	{
+		.type =       SOCK_RAW,
+		.protocol =   IPPROTO_IP,	/* wild card */
+		.prot =       &raw_prot,
+		.ops =        &inet_sockraw_ops,
+		.no_check =   UDP_CSUM_DEFAULT,
+		.flags =      INET_PROTOSW_REUSE,
+	}
 };
 
 #define INETSW_ARRAY_LEN ARRAY_SIZE(inetsw_array)
@@ -1187,7 +1187,8 @@ int inet_sk_rebuild_header(struct sock *sk)
 		daddr = inet_opt->opt.faddr;
 	rcu_read_unlock();
 	fl4 = &inet->cork.fl.u.ip4;
-	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr, inet->inet_saddr,
+	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr,
+				   inet->inet_saddr,
 				   inet->inet_dport, inet->inet_sport,
 				   sk->sk_protocol, RT_CONN_FLAGS(sk),
 				   sk->sk_bound_dev_if);
@@ -1200,14 +1201,19 @@ int inet_sk_rebuild_header(struct sock *sk)
 		/* Routing failed... */
 		sk->sk_route_caps = 0;
 		/*
-		 * Other protocols have to map its equivalent state to TCP_SYN_SENT.
+		 * Other protocols have to map its equivalent state
+		 * to TCP_SYN_SENT.
 		 * DCCP maps its DCCP_REQUESTING state to TCP_SYN_SENT. -acme
 		 */
 		if (!sysctl_ip_dynaddr ||
 		    sk->sk_state != TCP_SYN_SENT ||
-		    (sk->sk_userlocks & SOCK_BINDADDR_LOCK) ||
-		    (err = inet_sk_reselect_saddr(sk)) != 0)
+		    (sk->sk_userlocks & SOCK_BINDADDR_LOCK)) {
 			sk->sk_err_soft = -err;
+		} else {
+			err = inet_sk_reselect_saddr(sk);
+			if (err != 0)
+				sk->sk_err_soft = -err;
+		}
 	}
 
 	return err;
@@ -1354,7 +1360,8 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		goto out_unlock;
 
 	id = ntohl(*(__be32 *)&iph->id);
-	flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP_DF));
+	flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) |
+		(id ^ IP_DF));
 	id >>= 16;
 
 	for (p = *head; p; p = p->next) {
@@ -1455,7 +1462,7 @@ unsigned long snmp_fold_field(void __percpu *mib[], int offt)
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
-#if BITS_PER_LONG==32
+#if BITS_PER_LONG == 32
 
 u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
 {
-- 
1.7.5.4
