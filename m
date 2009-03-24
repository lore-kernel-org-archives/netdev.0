From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/41: x_tables: remove unneeded initializations
Date: Tue, 24 Mar 2009 15:03:12 +0100 (MET)
Message-ID: <20090324140308.31401.86155.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758057AbZCXODO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:14 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9c8222b9e71b690c8388bb0ebe5c3e5a1469e884
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed Feb 18 16:30:20 2009 +0100

    netfilter: x_tables: remove unneeded initializations
    
    Later patches change the locking on xt_table and the initialization of
    the lock element is not needed since the lock is always initialized in
    xt_table_register anyway.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index e091187..6ecfdae 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -48,8 +48,6 @@ static struct
 static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),
-	.private	= NULL,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_ARP,
 };
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 52cb693..c30a969 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -56,7 +56,6 @@ static struct
 static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 3929d20..4087614 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -67,7 +67,6 @@ static struct
 static struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_mangler.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 7f65d18..e5356da 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -39,7 +39,6 @@ static struct
 static struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks =  RAW_VALID_HOOKS,
-	.lock = __RW_LOCK_UNLOCKED(packet_raw.lock),
 	.me = THIS_MODULE,
 	.af = AF_INET,
 };
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index a52a35f..29ab630 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -60,7 +60,6 @@ static struct
 static struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(security_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index a7eb047..6348a79 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -61,7 +61,6 @@ static struct
 static struct xt_table nat_table = {
 	.name		= "nat",
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(nat_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 40d2e36..ef5a0a3 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -54,7 +54,6 @@ static struct
 static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET6,
 };
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index d0b31b2..ab0d398 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -60,7 +60,6 @@ static struct
 static struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_mangler.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET6,
 };
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 109fab6..4b792b6 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -38,7 +38,6 @@ static struct
 static struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks = RAW_VALID_HOOKS,
-	.lock = __RW_LOCK_UNLOCKED(packet_raw.lock),
 	.me = THIS_MODULE,
 	.af = AF_INET6,
 };
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 20bc52f..0ea37ff 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -59,7 +59,6 @@ static struct
 static struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(security_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET6,
 };
