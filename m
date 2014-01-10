From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/23] netfilter: nf_tables: fix error path in the init functions
Date: Fri, 10 Jan 2014 01:35:42 +0100
Message-ID: <1389314142-17969-24-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51593 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757449AbaAJAgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:17 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to unregister chain type if this fails to register netns.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_tables_ipv4.c |    8 +++++++-
 net/ipv6/netfilter/nf_tables_ipv6.c |    8 +++++++-
 net/netfilter/nf_tables_inet.c      |    8 +++++++-
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index fec163a..6820c8c 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -105,8 +105,14 @@ static const struct nf_chain_type filter_ipv4 = {
 
 static int __init nf_tables_ipv4_init(void)
 {
+	int ret;
+
 	nft_register_chain_type(&filter_ipv4);
-	return register_pernet_subsys(&nf_tables_ipv4_net_ops);
+	ret = register_pernet_subsys(&nf_tables_ipv4_net_ops);
+	if (ret < 0)
+		nft_unregister_chain_type(&filter_ipv4);
+
+	return ret;
 }
 
 static void __exit nf_tables_ipv4_exit(void)
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 59a43b4..0d812b3 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -104,8 +104,14 @@ static const struct nf_chain_type filter_ipv6 = {
 
 static int __init nf_tables_ipv6_init(void)
 {
+	int ret;
+
 	nft_register_chain_type(&filter_ipv6);
-	return register_pernet_subsys(&nf_tables_ipv6_net_ops);
+	ret = register_pernet_subsys(&nf_tables_ipv6_net_ops);
+	if (ret < 0)
+		nft_unregister_chain_type(&filter_ipv6);
+
+	return ret;
 }
 
 static void __exit nf_tables_ipv6_exit(void)
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
index 84478de..9dd2d21 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -80,8 +80,14 @@ static const struct nf_chain_type filter_inet = {
 
 static int __init nf_tables_inet_init(void)
 {
+	int ret;
+
 	nft_register_chain_type(&filter_inet);
-	return register_pernet_subsys(&nf_tables_inet_net_ops);
+	ret = register_pernet_subsys(&nf_tables_inet_net_ops);
+	if (ret < 0)
+		nft_unregister_chain_type(&filter_inet);
+
+	return ret;
 }
 
 static void __exit nf_tables_inet_exit(void)
-- 
1.7.10.4
