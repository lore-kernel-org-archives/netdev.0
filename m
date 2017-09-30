From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH 2/2] net: phonet: mark phonet_protocol as const
Date: Sat, 30 Sep 2017 17:11:03 +0800
Message-ID: <1506762663-4907-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, courmisch@gmail.com,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37902 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdI3JMM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 05:12:12 -0400
Received: by mail-pg0-f67.google.com with SMTP id y192so1305892pgd.5
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 02:12:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phonet_protocol structs don't need to be written by anyone and
so can be marked as const.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 include/net/phonet/phonet.h |  6 ++++--
 net/phonet/af_phonet.c      | 15 ++++++++-------
 net/phonet/datagram.c       |  2 +-
 net/phonet/pep.c            |  2 +-
 4 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 039cc29..51e1a2a 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -108,8 +108,10 @@ struct phonet_protocol {
 	int			sock_type;
 };
 
-int phonet_proto_register(unsigned int protocol, struct phonet_protocol *pp);
-void phonet_proto_unregister(unsigned int protocol, struct phonet_protocol *pp);
+int phonet_proto_register(unsigned int protocol,
+		const struct phonet_protocol *pp);
+void phonet_proto_unregister(unsigned int protocol,
+		const struct phonet_protocol *pp);
 
 int phonet_sysctl_init(void);
 void phonet_sysctl_exit(void);
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index b12142e..3b0ef69 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -35,11 +35,11 @@
 #include <net/phonet/pn_dev.h>
 
 /* Transport protocol registration */
-static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
+static const struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
 
-static struct phonet_protocol *phonet_proto_get(unsigned int protocol)
+static const struct phonet_protocol *phonet_proto_get(unsigned int protocol)
 {
-	struct phonet_protocol *pp;
+	const struct phonet_protocol *pp;
 
 	if (protocol >= PHONET_NPROTO)
 		return NULL;
@@ -53,7 +53,7 @@ static struct phonet_protocol *phonet_proto_get(unsigned int protocol)
 	return pp;
 }
 
-static inline void phonet_proto_put(struct phonet_protocol *pp)
+static inline void phonet_proto_put(const struct phonet_protocol *pp)
 {
 	module_put(pp->prot->owner);
 }
@@ -65,7 +65,7 @@ static int pn_socket_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 	struct pn_sock *pn;
-	struct phonet_protocol *pnp;
+	const struct phonet_protocol *pnp;
 	int err;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -470,7 +470,7 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 static DEFINE_MUTEX(proto_tab_lock);
 
 int __init_or_module phonet_proto_register(unsigned int protocol,
-						struct phonet_protocol *pp)
+				const struct phonet_protocol *pp)
 {
 	int err = 0;
 
@@ -492,7 +492,8 @@ int __init_or_module phonet_proto_register(unsigned int protocol,
 }
 EXPORT_SYMBOL(phonet_proto_register);
 
-void phonet_proto_unregister(unsigned int protocol, struct phonet_protocol *pp)
+void phonet_proto_unregister(unsigned int protocol,
+			const struct phonet_protocol *pp)
 {
 	mutex_lock(&proto_tab_lock);
 	BUG_ON(proto_tab[protocol] != pp);
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 5e71043..b44fb90 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -195,7 +195,7 @@ static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	.name		= "PHONET",
 };
 
-static struct phonet_protocol pn_dgram_proto = {
+static const struct phonet_protocol pn_dgram_proto = {
 	.ops		= &phonet_dgram_ops,
 	.prot		= &pn_proto,
 	.sock_type	= SOCK_DGRAM,
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index e815379..9fc76b1 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1351,7 +1351,7 @@ static void pep_sock_unhash(struct sock *sk)
 	.name		= "PNPIPE",
 };
 
-static struct phonet_protocol pep_pn_proto = {
+static const struct phonet_protocol pep_pn_proto = {
 	.ops		= &phonet_stream_ops,
 	.prot		= &pep_proto,
 	.sock_type	= SOCK_SEQPACKET,
-- 
1.8.3.1
