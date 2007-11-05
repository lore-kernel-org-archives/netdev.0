From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 4/4] NET : makes sctp use the  {DEFINE|REF}_PROTO_INUSE infrastructure
Date: Mon, 05 Nov 2007 19:03:34 +0100
Message-ID: <472F5AF6.1030208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040103030102080502080006"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:7602 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015AbXKESDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 13:03:36 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f26.orange.fr (SMTP Server) with ESMTP id 7A90E70000A5
	for <netdev@vger.kernel.org>; Mon,  5 Nov 2007 19:03:35 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040103030102080502080006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trivial patch to make "sctcp,sctpv6" protocols uses the fast "inuse 
sockets" infrastructure

Each protocol use then a static percpu var, instead of a dynamic one. 
This saves some ram and some cpu cycles


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------040103030102080502080006
Content-Type: text/plain;
 name="prot_inuse_sctp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prot_inuse_sctp.patch"

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bd6f42a..a7ecf31 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6455,6 +6455,8 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 }
 
 
+DEFINE_PROTO_INUSE(sctp)
+
 /* This proto struct describes the ULP interface for SCTP.  */
 struct proto sctp_prot = {
 	.name        =	"SCTP",
@@ -6483,9 +6485,12 @@ struct proto sctp_prot = {
 	.memory_pressure = &sctp_memory_pressure,
 	.enter_memory_pressure = sctp_enter_memory_pressure,
 	.memory_allocated = &sctp_memory_allocated,
+	REF_PROTO_INUSE(sctp)
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+DEFINE_PROTO_INUSE(sctpv6)
+
 struct proto sctpv6_prot = {
 	.name		= "SCTPv6",
 	.owner		= THIS_MODULE,
@@ -6513,5 +6518,6 @@ struct proto sctpv6_prot = {
 	.memory_pressure = &sctp_memory_pressure,
 	.enter_memory_pressure = sctp_enter_memory_pressure,
 	.memory_allocated = &sctp_memory_allocated,
+	REF_PROTO_INUSE(sctpv6)
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */

--------------040103030102080502080006--


