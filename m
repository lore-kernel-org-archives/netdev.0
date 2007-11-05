From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 2/4] NET : makes ipv4 use the  {DEFINE|REF}_PROTO_INUSE infrastructure
Date: Mon, 05 Nov 2007 18:59:28 +0100
Message-ID: <472F5A00.6010700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050505050202070804060901"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:64810 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbXKER7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 12:59:36 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f26.orange.fr (SMTP Server) with ESMTP id 4481570000B7
	for <netdev@vger.kernel.org>; Mon,  5 Nov 2007 18:59:35 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050505050202070804060901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trivial patch to make "tcp,udp,udplite,raw" protocols uses the fast 
"inuse sockets" infrastructure

Each protocol use then a static percpu var, instead of a dynamic one. 
This saves some ram and some cpu cycles


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/ipv4/raw.c      |    3 +++
 net/ipv4/tcp_ipv4.c |    3 +++
 net/ipv4/udp.c      |    3 +++
 net/ipv4/udplite.c  |    3 +++
 4 files changed, 12 insertions(+)


--------------050505050202070804060901
Content-Type: text/plain;
 name="prot_inuse_ipv4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prot_inuse_ipv4.patch"

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3916fac..66b42f5 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -760,6 +760,8 @@ static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	}
 }
 
+DEFINE_PROTO_INUSE(raw)
+
 struct proto raw_prot = {
 	.name		   = "RAW",
 	.owner		   = THIS_MODULE,
@@ -781,6 +783,7 @@ struct proto raw_prot = {
 	.compat_setsockopt = compat_raw_setsockopt,
 	.compat_getsockopt = compat_raw_getsockopt,
 #endif
+	REF_PROTO_INUSE(raw)
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index eec02b2..a5c8e4b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2417,6 +2417,8 @@ void tcp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
+DEFINE_PROTO_INUSE(tcp)
+
 struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
@@ -2451,6 +2453,7 @@ struct proto tcp_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
+	REF_PROTO_INUSE(tcp)
 };
 
 void __init tcp_v4_init(struct net_proto_family *ops)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4bc25b4..03c400c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1430,6 +1430,8 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 }
 
+DEFINE_PROTO_INUSE(udp)
+
 struct proto udp_prot = {
 	.name		   = "UDP",
 	.owner		   = THIS_MODULE,
@@ -1452,6 +1454,7 @@ struct proto udp_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
+	REF_PROTO_INUSE(udp)
 };
 
 /* ------------------------------------------------------------------------ */
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 9497720..f5baeb3 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -44,6 +44,8 @@ static	struct net_protocol udplite_protocol = {
 	.no_policy	= 1,
 };
 
+DEFINE_PROTO_INUSE(udplite)
+
 struct proto 	udplite_prot = {
 	.name		   = "UDP-Lite",
 	.owner		   = THIS_MODULE,
@@ -67,6 +69,7 @@ struct proto 	udplite_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
+	REF_PROTO_INUSE(udplite)
 };
 
 static struct inet_protosw udplite4_protosw = {

--------------050505050202070804060901--


