From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 61/62: ebtables: avoid explicit XT_ALIGN() in match/targets
Date: Tue, 16 Feb 2010 15:56:42 +0100 (MET)
Message-ID: <20100216145640.2796.35967.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52133 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932850Ab0BPO4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:43 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fc0e3df4f00a5f62c2f2fce84bf496136b58c474
Author: Florian Westphal <fwestphal@astaro.com>
Date:   Mon Feb 15 18:16:26 2010 +0100

    netfilter: ebtables: avoid explicit XT_ALIGN() in match/targets
    
    This will cause trouble once CONFIG_COMPAT support is added to ebtables.
    xt_compat_*_offset() calculate the kernel/userland structure size delta
    using:
    
    XT_ALIGN(size) - COMPAT_XT_ALIGN(size)
    
    If the match/target sizes are aligned at registration time,
    delta is always zero.
    
    Should have zero effect for existing systems: xtables uses
    XT_ALIGN() whenever it deals with match/target sizes.
    
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
index bd91dc5..5d11767 100644
--- a/net/bridge/netfilter/ebt_802_3.c
+++ b/net/bridge/netfilter/ebt_802_3.c
@@ -52,7 +52,7 @@ static struct xt_match ebt_802_3_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_802_3_mt,
 	.checkentry	= ebt_802_3_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_802_3_info)),
+	.matchsize	= sizeof(struct ebt_802_3_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index b7ad604..e727697 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -120,7 +120,7 @@ static struct xt_match ebt_arp_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_arp_mt,
 	.checkentry	= ebt_arp_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_arp_info)),
+	.matchsize	= sizeof(struct ebt_arp_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index 76584cd..f392e9d 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -78,7 +78,7 @@ static struct xt_target ebt_arpreply_tg_reg __read_mostly = {
 	.hooks		= (1 << NF_BR_NUMHOOKS) | (1 << NF_BR_PRE_ROUTING),
 	.target		= ebt_arpreply_tg,
 	.checkentry	= ebt_arpreply_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_arpreply_info)),
+	.targetsize	= sizeof(struct ebt_arpreply_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 6b49ea9..2bb40d7 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -54,7 +54,7 @@ static struct xt_target ebt_dnat_tg_reg __read_mostly = {
 			  (1 << NF_BR_LOCAL_OUT) | (1 << NF_BR_BROUTING),
 	.target		= ebt_dnat_tg,
 	.checkentry	= ebt_dnat_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_nat_info)),
+	.targetsize	= sizeof(struct ebt_nat_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index d771bbf..5de6df6 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -110,7 +110,7 @@ static struct xt_match ebt_ip_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_ip_mt,
 	.checkentry	= ebt_ip_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_ip_info)),
+	.matchsize	= sizeof(struct ebt_ip_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 784a657..bbf2534 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -122,7 +122,7 @@ static struct xt_match ebt_ip6_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_ip6_mt,
 	.checkentry	= ebt_ip6_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_ip6_info)),
+	.matchsize	= sizeof(struct ebt_ip6_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index f7bd919..9dd16e6 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -90,7 +90,7 @@ static struct xt_match ebt_limit_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_limit_mt,
 	.checkentry	= ebt_limit_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_limit_info)),
+	.matchsize	= sizeof(struct ebt_limit_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index e4ea3fd..e873924 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -195,7 +195,7 @@ static struct xt_target ebt_log_tg_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.target		= ebt_log_tg,
 	.checkentry	= ebt_log_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_log_info)),
+	.targetsize	= sizeof(struct ebt_log_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mark.c
index 2fee7e8..153e167 100644
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -59,7 +59,7 @@ static struct xt_target ebt_mark_tg_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.target		= ebt_mark_tg,
 	.checkentry	= ebt_mark_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_mark_t_info)),
+	.targetsize	= sizeof(struct ebt_mark_t_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_mark_m.c b/net/bridge/netfilter/ebt_mark_m.c
index ea570f2..89abf40 100644
--- a/net/bridge/netfilter/ebt_mark_m.c
+++ b/net/bridge/netfilter/ebt_mark_m.c
@@ -41,7 +41,7 @@ static struct xt_match ebt_mark_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_mark_mt,
 	.checkentry	= ebt_mark_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_mark_m_info)),
+	.matchsize	= sizeof(struct ebt_mark_m_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 2a63d99..40dbd24 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -51,7 +51,7 @@ static struct xt_target ebt_nflog_tg_reg __read_mostly = {
 	.family     = NFPROTO_BRIDGE,
 	.target     = ebt_nflog_tg,
 	.checkentry = ebt_nflog_tg_check,
-	.targetsize = XT_ALIGN(sizeof(struct ebt_nflog_info)),
+	.targetsize = sizeof(struct ebt_nflog_info),
 	.me         = THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_pkttype.c b/net/bridge/netfilter/ebt_pkttype.c
index 883e96e..e2a07e6 100644
--- a/net/bridge/netfilter/ebt_pkttype.c
+++ b/net/bridge/netfilter/ebt_pkttype.c
@@ -36,7 +36,7 @@ static struct xt_match ebt_pkttype_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_pkttype_mt,
 	.checkentry	= ebt_pkttype_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_pkttype_info)),
+	.matchsize	= sizeof(struct ebt_pkttype_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index c8a49f7..9be8fbc 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -59,7 +59,7 @@ static struct xt_target ebt_redirect_tg_reg __read_mostly = {
 			  (1 << NF_BR_BROUTING),
 	.target		= ebt_redirect_tg,
 	.checkentry	= ebt_redirect_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_redirect_info)),
+	.targetsize	= sizeof(struct ebt_redirect_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index 8d04d4c..9c7b520 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -67,7 +67,7 @@ static struct xt_target ebt_snat_tg_reg __read_mostly = {
 	.hooks		= (1 << NF_BR_NUMHOOKS) | (1 << NF_BR_POST_ROUTING),
 	.target		= ebt_snat_tg,
 	.checkentry	= ebt_snat_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_nat_info)),
+	.targetsize	= sizeof(struct ebt_nat_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 75e29a9..92a93d3 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -177,7 +177,7 @@ static struct xt_match ebt_stp_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_stp_mt,
 	.checkentry	= ebt_stp_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_stp_info)),
+	.matchsize	= sizeof(struct ebt_stp_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index ce50688..c6ac657 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -275,7 +275,7 @@ static struct xt_target ebt_ulog_tg_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.target		= ebt_ulog_tg,
 	.checkentry	= ebt_ulog_tg_check,
-	.targetsize	= XT_ALIGN(sizeof(struct ebt_ulog_info)),
+	.targetsize	= sizeof(struct ebt_ulog_info),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index 3dddd48..be1dd2e 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -163,7 +163,7 @@ static struct xt_match ebt_vlan_mt_reg __read_mostly = {
 	.family		= NFPROTO_BRIDGE,
 	.match		= ebt_vlan_mt,
 	.checkentry	= ebt_vlan_mt_check,
-	.matchsize	= XT_ALIGN(sizeof(struct ebt_vlan_info)),
+	.matchsize	= sizeof(struct ebt_vlan_info),
 	.me		= THIS_MODULE,
 };
 
