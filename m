From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 13/31: xtables: switch hook PFs to nfproto
Date: Thu, 10 Sep 2009 18:12:03 +0200 (MEST)
Message-ID: <20090910161159.31179.54715.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64663 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbZIJQMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:12:01 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 24c232d8e911ef6189e02da411dc2b72cb03bfcf
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jun 13 06:20:29 2009 +0200

    netfilter: xtables: switch hook PFs to nfproto
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index a5eea72..4b988db 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -77,21 +77,21 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 	{
 		.hook		= ebt_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_BRIDGE,
+		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_IN,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
 		.hook		= ebt_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_BRIDGE,
+		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_FORWARD,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
 		.hook		= ebt_out_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_BRIDGE,
+		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
 		.priority	= NF_BR_PRI_FILTER_OTHER,
 	},
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 6024c55..4a98804 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -77,21 +77,21 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 	{
 		.hook		= ebt_nat_out,
 		.owner		= THIS_MODULE,
-		.pf		= PF_BRIDGE,
+		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
 		.priority	= NF_BR_PRI_NAT_DST_OTHER,
 	},
 	{
 		.hook		= ebt_nat_out,
 		.owner		= THIS_MODULE,
-		.pf		= PF_BRIDGE,
+		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_POST_ROUTING,
 		.priority	= NF_BR_PRI_NAT_SRC,
 	},
 	{
 		.hook		= ebt_nat_in,
 		.owner		= THIS_MODULE,
-		.pf		= PF_BRIDGE,
+		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_PRE_ROUTING,
 		.priority	= NF_BR_PRI_NAT_DST_BRIDGED,
 	},
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index c30a969..bef326c 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -102,21 +102,21 @@ static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
 		.hook		= ipt_local_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
 		.hook		= ipt_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
 		.hook		= ipt_local_out_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_FILTER,
 	},
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 4087614..1442df7 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -162,35 +162,35 @@ static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
 		.hook		= ipt_pre_routing_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_local_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_forward_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_local_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_post_routing_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index e5356da..1d28df8 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -74,14 +74,14 @@ ipt_local_hook(unsigned int hook,
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
 		.hook = ipt_hook,
-		.pf = PF_INET,
+		.pf = NFPROTO_IPV4,
 		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP_PRI_RAW,
 		.owner = THIS_MODULE,
 	},
 	{
 		.hook = ipt_local_hook,
-		.pf = PF_INET,
+		.pf = NFPROTO_IPV4,
 		.hooknum = NF_INET_LOCAL_OUT,
 		.priority = NF_IP_PRI_RAW,
 		.owner = THIS_MODULE,
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 29ab630..8c5a250 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -105,21 +105,21 @@ static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
 		.hook		= ipt_local_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_SECURITY,
 	},
 	{
 		.hook		= ipt_forward_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_SECURITY,
 	},
 	{
 		.hook		= ipt_local_out_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_SECURITY,
 	},
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 5567bd0..5f41d01 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -251,7 +251,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	{
 		.hook		= nf_nat_in,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_NAT_DST,
 	},
@@ -259,7 +259,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	{
 		.hook		= nf_nat_out,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_NAT_SRC,
 	},
@@ -267,7 +267,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	{
 		.hook		= nf_nat_local_fn,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST,
 	},
@@ -275,7 +275,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	{
 		.hook		= nf_nat_fn,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC,
 	},
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index ef5a0a3..b35c358 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -95,21 +95,21 @@ static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
 		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
 		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
 		.hook		= ip6t_local_out_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index ab0d398..a98ced1 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -136,35 +136,35 @@ static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
 		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_local_out_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_post_routing_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 4b792b6..ec12540 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -68,14 +68,14 @@ ip6t_local_out_hook(unsigned int hook,
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
 	  .hook = ip6t_pre_routing_hook,
-	  .pf = PF_INET6,
+	  .pf = NFPROTO_IPV6,
 	  .hooknum = NF_INET_PRE_ROUTING,
 	  .priority = NF_IP6_PRI_FIRST,
 	  .owner = THIS_MODULE,
 	},
 	{
 	  .hook = ip6t_local_out_hook,
-	  .pf = PF_INET6,
+	  .pf = NFPROTO_IPV6,
 	  .hooknum = NF_INET_LOCAL_OUT,
 	  .priority = NF_IP6_PRI_FIRST,
 	  .owner = THIS_MODULE,
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 0ea37ff..d808507 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -101,21 +101,21 @@ static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
 		.hook		= ip6t_local_in_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_SECURITY,
 	},
 	{
 		.hook		= ip6t_forward_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_SECURITY,
 	},
 	{
 		.hook		= ip6t_local_out_hook,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_SECURITY,
 	},
