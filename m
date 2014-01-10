From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/23] netfilter: nf_tables: add missing module references to chain types
Date: Fri, 10 Jan 2014 01:35:34 +0100
Message-ID: <1389314142-17969-16-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51562 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757219AbaAJAgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:12 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

In some cases we neither take a reference to the AF info nor to the
chain type, allowing the module to be unloaded while in use.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c |    1 +
 net/ipv4/netfilter/nf_tables_arp.c      |    1 +
 net/ipv4/netfilter/nf_tables_ipv4.c     |    1 +
 net/ipv6/netfilter/nf_tables_ipv6.c     |    1 +
 net/netfilter/nf_tables_inet.c          |    1 +
 5 files changed, 5 insertions(+)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 003c1e9..f97222e 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -72,6 +72,7 @@ static struct nf_chain_type filter_bridge = {
 	.family		= NFPROTO_BRIDGE,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
+	.me		= THIS_MODULE,
 	.hook_mask	= (1 << NF_BR_LOCAL_IN) |
 			  (1 << NF_BR_FORWARD) |
 			  (1 << NF_BR_LOCAL_OUT),
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 36d27fc..228df00 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -72,6 +72,7 @@ static struct nf_chain_type filter_arp = {
 	.family		= NFPROTO_ARP,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
+	.me		= THIS_MODULE,
 	.hook_mask	= (1 << NF_ARP_IN) |
 			  (1 << NF_ARP_OUT) |
 			  (1 << NF_ARP_FORWARD),
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index da927dc..d6fc1b4 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -95,6 +95,7 @@ static struct nf_chain_type filter_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
+	.me		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 025e7f4..a340276 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -94,6 +94,7 @@ static struct nf_chain_type filter_ipv6 = {
 	.family		= NFPROTO_IPV6,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
+	.me		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
index ac0edcb..280d3a2 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -70,6 +70,7 @@ static struct nf_chain_type filter_inet = {
 	.family		= NFPROTO_INET,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
+	.me		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
-- 
1.7.10.4
