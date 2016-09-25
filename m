From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/53] netfilter: Add the missed return value check of nft_register_chain_type
Date: Mon, 26 Sep 2016 01:06:32 +0200
Message-ID: <1474844823-2026-23-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54660 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034726AbcIYXHq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:46 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9AD07C0B3F
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 88F98DA81B
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9B492DA84C
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:39 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are some codes of netfilter module which did not check the return
value of nft_register_chain_type. Add the checks now.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c | 18 +++++++++++++-----
 net/ipv4/netfilter/nf_tables_arp.c      |  5 ++++-
 net/ipv4/netfilter/nf_tables_ipv4.c     |  5 ++++-
 net/ipv6/netfilter/nf_tables_ipv6.c     |  5 ++++-
 net/netfilter/nf_tables_inet.c          |  5 ++++-
 net/netfilter/nf_tables_netdev.c        |  5 ++++-
 6 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 06f0f81456a0..97afdc0744e6 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -139,12 +139,20 @@ static int __init nf_tables_bridge_init(void)
 	int ret;
 
 	nf_register_afinfo(&nf_br_afinfo);
-	nft_register_chain_type(&filter_bridge);
+	ret = nft_register_chain_type(&filter_bridge);
+	if (ret < 0)
+		goto err1;
+
 	ret = register_pernet_subsys(&nf_tables_bridge_net_ops);
-	if (ret < 0) {
-		nft_unregister_chain_type(&filter_bridge);
-		nf_unregister_afinfo(&nf_br_afinfo);
-	}
+	if (ret < 0)
+		goto err2;
+
+	return ret;
+
+err2:
+	nft_unregister_chain_type(&filter_bridge);
+err1:
+	nf_unregister_afinfo(&nf_br_afinfo);
 	return ret;
 }
 
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 058c034be376..805c8ddfe860 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -80,7 +80,10 @@ static int __init nf_tables_arp_init(void)
 {
 	int ret;
 
-	nft_register_chain_type(&filter_arp);
+	ret = nft_register_chain_type(&filter_arp);
+	if (ret < 0)
+		return ret;
+
 	ret = register_pernet_subsys(&nf_tables_arp_net_ops);
 	if (ret < 0)
 		nft_unregister_chain_type(&filter_arp);
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index e44ba3b12fbb..2840a29b2e04 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -103,7 +103,10 @@ static int __init nf_tables_ipv4_init(void)
 {
 	int ret;
 
-	nft_register_chain_type(&filter_ipv4);
+	ret = nft_register_chain_type(&filter_ipv4);
+	if (ret < 0)
+		return ret;
+
 	ret = register_pernet_subsys(&nf_tables_ipv4_net_ops);
 	if (ret < 0)
 		nft_unregister_chain_type(&filter_ipv4);
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 05d05926962a..d6e4ba5de916 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -100,7 +100,10 @@ static int __init nf_tables_ipv6_init(void)
 {
 	int ret;
 
-	nft_register_chain_type(&filter_ipv6);
+	ret = nft_register_chain_type(&filter_ipv6);
+	if (ret < 0)
+		return ret;
+
 	ret = register_pernet_subsys(&nf_tables_ipv6_net_ops);
 	if (ret < 0)
 		nft_unregister_chain_type(&filter_ipv6);
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
index 6b5f76295d3d..f713cc205669 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -82,7 +82,10 @@ static int __init nf_tables_inet_init(void)
 {
 	int ret;
 
-	nft_register_chain_type(&filter_inet);
+	ret = nft_register_chain_type(&filter_inet);
+	if (ret < 0)
+		return ret;
+
 	ret = register_pernet_subsys(&nf_tables_inet_net_ops);
 	if (ret < 0)
 		nft_unregister_chain_type(&filter_inet);
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 38a3e8385042..9e2ae424b640 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -149,7 +149,10 @@ static int __init nf_tables_netdev_init(void)
 {
 	int ret;
 
-	nft_register_chain_type(&nft_filter_chain_netdev);
+	ret = nft_register_chain_type(&nft_filter_chain_netdev);
+	if (ret)
+		return ret;
+
 	ret = register_pernet_subsys(&nf_tables_netdev_net_ops);
 	if (ret)
 		goto err1;
-- 
2.1.4
