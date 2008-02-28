From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/4] [SCTP]: Clean up naming conventions of sctp protocol/address family registration
Date: Thu, 28 Feb 2008 16:52:39 -0500
Message-ID: <1204235561-19993-3-git-send-email-vladislav.yasevich@hp.com>
References: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:24358 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbYB1VwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:52:19 -0500
In-Reply-To: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

I noticed while looking into some odd behavior in sctp, that the variable
name sctp_pf_inet6_specific was used twice to represent two different
pieces of data (its both a structure name and a pointer to that type of
structure), which is confusing to say the least, and potentially dangerous
depending on the variable scope.  This patch cleans that up, and makes the
protocol and address family registration names in SCTP more regular,
increasing readability.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

 ipv6.c     |   12 ++++++------
 protocol.c |   12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)
---
 net/sctp/ipv6.c     |   12 ++++++------
 net/sctp/protocol.c |   12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 4d7ec96..87f9405 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -966,7 +966,7 @@ static struct inet6_protocol sctpv6_protocol = {
 	.flags        = INET6_PROTO_NOPOLICY | INET6_PROTO_FINAL,
 };
 
-static struct sctp_af sctp_ipv6_specific = {
+static struct sctp_af sctp_af_inet6 = {
 	.sa_family	   = AF_INET6,
 	.sctp_xmit	   = sctp_v6_xmit,
 	.setsockopt	   = ipv6_setsockopt,
@@ -998,7 +998,7 @@ static struct sctp_af sctp_ipv6_specific = {
 #endif
 };
 
-static struct sctp_pf sctp_pf_inet6_specific = {
+static struct sctp_pf sctp_pf_inet6 = {
 	.event_msgname = sctp_inet6_event_msgname,
 	.skb_msgname   = sctp_inet6_skb_msgname,
 	.af_supported  = sctp_inet6_af_supported,
@@ -1008,7 +1008,7 @@ static struct sctp_pf sctp_pf_inet6_specific = {
 	.supported_addrs = sctp_inet6_supported_addrs,
 	.create_accept_sk = sctp_v6_create_accept_sk,
 	.addr_v4map    = sctp_v6_addr_v4map,
-	.af            = &sctp_ipv6_specific,
+	.af            = &sctp_af_inet6,
 };
 
 /* Initialize IPv6 support and register with socket layer.  */
@@ -1017,10 +1017,10 @@ int sctp_v6_init(void)
 	int rc;
 
 	/* Register the SCTP specific PF_INET6 functions. */
-	sctp_register_pf(&sctp_pf_inet6_specific, PF_INET6);
+	sctp_register_pf(&sctp_pf_inet6, PF_INET6);
 
 	/* Register the SCTP specific AF_INET6 functions. */
-	sctp_register_af(&sctp_ipv6_specific);
+	sctp_register_af(&sctp_af_inet6);
 
 	rc = proto_register(&sctpv6_prot, 1);
 	if (rc)
@@ -1051,7 +1051,7 @@ void sctp_v6_exit(void)
 	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
 	inet6_unregister_protosw(&sctpv6_stream_protosw);
 	proto_unregister(&sctpv6_prot);
-	list_del(&sctp_ipv6_specific.list);
+	list_del(&sctp_af_inet6.list);
 }
 
 /* Unregister with inet6 layer. */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 22a1657..688546d 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -832,7 +832,7 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 	return ip_queue_xmit(skb, ipfragok);
 }
 
-static struct sctp_af sctp_ipv4_specific;
+static struct sctp_af sctp_af_inet;
 
 static struct sctp_pf sctp_pf_inet = {
 	.event_msgname = sctp_inet_event_msgname,
@@ -844,7 +844,7 @@ static struct sctp_pf sctp_pf_inet = {
 	.supported_addrs = sctp_inet_supported_addrs,
 	.create_accept_sk = sctp_v4_create_accept_sk,
 	.addr_v4map	= sctp_v4_addr_v4map,
-	.af            = &sctp_ipv4_specific,
+	.af            = &sctp_af_inet
 };
 
 /* Notifier for inetaddr addition/deletion events.  */
@@ -906,7 +906,7 @@ static struct net_protocol sctp_protocol = {
 };
 
 /* IPv4 address related functions.  */
-static struct sctp_af sctp_ipv4_specific = {
+static struct sctp_af sctp_af_inet = {
 	.sa_family	   = AF_INET,
 	.sctp_xmit	   = sctp_v4_xmit,
 	.setsockopt	   = ip_setsockopt,
@@ -1192,7 +1192,7 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_sysctl_register();
 
 	INIT_LIST_HEAD(&sctp_address_families);
-	sctp_register_af(&sctp_ipv4_specific);
+	sctp_register_af(&sctp_af_inet);
 
 	status = proto_register(&sctp_prot, 1);
 	if (status)
@@ -1249,7 +1249,7 @@ err_v6_init:
 	proto_unregister(&sctp_prot);
 err_proto_register:
 	sctp_sysctl_unregister();
-	list_del(&sctp_ipv4_specific.list);
+	list_del(&sctp_af_inet.list);
 	free_pages((unsigned long)sctp_port_hashtable,
 		   get_order(sctp_port_hashsize *
 			     sizeof(struct sctp_bind_hashbucket)));
@@ -1299,7 +1299,7 @@ SCTP_STATIC __exit void sctp_exit(void)
 	inet_unregister_protosw(&sctp_seqpacket_protosw);
 
 	sctp_sysctl_unregister();
-	list_del(&sctp_ipv4_specific.list);
+	list_del(&sctp_af_inet.list);
 
 	free_pages((unsigned long)sctp_assoc_hashtable,
 		   get_order(sctp_assoc_hashsize *
-- 
1.5.3.5

