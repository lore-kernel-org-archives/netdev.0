From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 3/4] NET : makes ipv6 use the  {DEFINE|REF}_PROTO_INUSE infrastructure
Date: Mon, 05 Nov 2007 19:02:25 +0100
Message-ID: <472F5AB1.8070809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010402000602060600000609"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:5006 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbXKESC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 13:02:27 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f26.orange.fr (SMTP Server) with ESMTP id B1F14700008B
	for <netdev@vger.kernel.org>; Mon,  5 Nov 2007 19:02:26 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010402000602060600000609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trivial patch to make "tcpv6,udpv6,udplitev6,rawv6" protocols uses the 
fast "inuse sockets" infrastructure

Each protocol use then a static percpu var, instead of a dynamic one. 
This saves some ram and some cpu cycles


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/ipv6/raw.c      |    3 +++
 net/ipv6/tcp_ipv6.c |    3 +++
 net/ipv6/udp.c      |    3 +++
 net/ipv6/udplite.c  |    3 +++
 4 files changed, 12 insertions(+)


--------------010402000602060600000609
Content-Type: text/plain;
 name="prot_inuse_ipv6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prot_inuse_ipv6.patch"

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ca24ef1..807260d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1144,6 +1144,8 @@ static int rawv6_init_sk(struct sock *sk)
 	return(0);
 }
 
+DEFINE_PROTO_INUSE(rawv6)
+
 struct proto rawv6_prot = {
 	.name		   = "RAWv6",
 	.owner		   = THIS_MODULE,
@@ -1166,6 +1168,7 @@ struct proto rawv6_prot = {
 	.compat_setsockopt = compat_rawv6_setsockopt,
 	.compat_getsockopt = compat_rawv6_getsockopt,
 #endif
+	REF_PROTO_INUSE(rawv6)
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4b90328..c7b8921 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2107,6 +2107,8 @@ void tcp6_proc_exit(void)
 }
 #endif
 
+DEFINE_PROTO_INUSE(tcpv6)
+
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
@@ -2141,6 +2143,7 @@ struct proto tcpv6_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
+	REF_PROTO_INUSE(tcpv6)
 };
 
 static struct inet6_protocol tcpv6_protocol = {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index caebad6..d198ed4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -971,6 +971,8 @@ void udp6_proc_exit(void) {
 
 /* ------------------------------------------------------------------------ */
 
+DEFINE_PROTO_INUSE(udpv6)
+
 struct proto udpv6_prot = {
 	.name		   = "UDPv6",
 	.owner		   = THIS_MODULE,
@@ -992,6 +994,7 @@ struct proto udpv6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
+	REF_PROTO_INUSE(udpv6)
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 766566f..5a0379f 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -40,6 +40,8 @@ static int udplite_v6_get_port(struct sock *sk, unsigned short snum)
 	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
 
+DEFINE_PROTO_INUSE(udplitev6)
+
 struct proto udplitev6_prot = {
 	.name		   = "UDPLITEv6",
 	.owner		   = THIS_MODULE,
@@ -62,6 +64,7 @@ struct proto udplitev6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
+	REF_PROTO_INUSE(udplitev6)
 };
 
 static struct inet_protosw udplite6_protosw = {

--------------010402000602060600000609--


