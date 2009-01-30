From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] netfilter: remove unneeded initializations
Date: Fri, 30 Jan 2009 13:57:02 -0800
Message-ID: <20090130215729.160828979@vyatta.com>
References: <20090130215700.965611970@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49655 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756935AbZA3V57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:57:59 -0500
Content-Disposition: inline; filename=iptables-lock-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later patches change the locking on xt_table and the initialization of
the lock element is not needed since the lock is always initialized in
xt_table_register anyway.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv4/netfilter/arptable_filter.c   |    2 --
 net/ipv4/netfilter/iptable_filter.c    |    1 -
 net/ipv4/netfilter/iptable_mangle.c    |    1 -
 net/ipv4/netfilter/iptable_raw.c       |    1 -
 net/ipv4/netfilter/iptable_security.c  |    1 -
 net/ipv4/netfilter/nf_nat_rule.c       |    1 -
 net/ipv6/netfilter/ip6table_filter.c   |    1 -
 net/ipv6/netfilter/ip6table_mangle.c   |    1 -
 net/ipv6/netfilter/ip6table_raw.c      |    1 -
 net/ipv6/netfilter/ip6table_security.c |    1 -
 10 files changed, 11 deletions(-)

--- a/net/ipv4/netfilter/arptable_filter.c	2009-01-26 17:24:43.687542005 -0800
+++ b/net/ipv4/netfilter/arptable_filter.c	2009-01-26 19:50:37.891042244 -0800
@@ -48,8 +48,6 @@ static struct
 static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),
-	.private	= NULL,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_ARP,
 };
--- a/net/ipv4/netfilter/iptable_filter.c	2009-01-26 17:24:43.691541994 -0800
+++ b/net/ipv4/netfilter/iptable_filter.c	2009-01-26 19:50:37.891042244 -0800
@@ -56,7 +56,6 @@ static struct
 static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
--- a/net/ipv4/netfilter/iptable_raw.c	2009-01-26 17:24:43.691541994 -0800
+++ b/net/ipv4/netfilter/iptable_raw.c	2009-01-26 19:50:37.891042244 -0800
@@ -39,7 +39,6 @@ static struct
 static struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks =  RAW_VALID_HOOKS,
-	.lock = __RW_LOCK_UNLOCKED(packet_raw.lock),
 	.me = THIS_MODULE,
 	.af = AF_INET,
 };
--- a/net/ipv4/netfilter/iptable_security.c	2009-01-26 17:24:43.691541994 -0800
+++ b/net/ipv4/netfilter/iptable_security.c	2009-01-26 19:50:37.891042244 -0800
@@ -60,7 +60,6 @@ static struct
 static struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(security_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
--- a/net/ipv4/netfilter/nf_nat_rule.c	2009-01-26 17:24:43.695541481 -0800
+++ b/net/ipv4/netfilter/nf_nat_rule.c	2009-01-26 19:51:20.338030618 -0800
@@ -61,7 +61,6 @@ static struct
 static struct xt_table nat_table = {
 	.name		= "nat",
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(nat_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
--- a/net/ipv6/netfilter/ip6table_filter.c	2009-01-26 17:24:43.735541493 -0800
+++ b/net/ipv6/netfilter/ip6table_filter.c	2009-01-26 19:50:37.895044361 -0800
@@ -54,7 +54,6 @@ static struct
 static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET6,
 };
--- a/net/ipv6/netfilter/ip6table_mangle.c	2009-01-26 17:24:43.735541493 -0800
+++ b/net/ipv6/netfilter/ip6table_mangle.c	2009-01-26 19:50:37.895044361 -0800
@@ -60,7 +60,6 @@ static struct
 static struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_mangler.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET6,
 };
--- a/net/ipv6/netfilter/ip6table_raw.c	2009-01-26 17:24:43.735541493 -0800
+++ b/net/ipv6/netfilter/ip6table_raw.c	2009-01-26 19:50:37.895044361 -0800
@@ -38,7 +38,6 @@ static struct
 static struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks = RAW_VALID_HOOKS,
-	.lock = __RW_LOCK_UNLOCKED(packet_raw.lock),
 	.me = THIS_MODULE,
 	.af = AF_INET6,
 };
--- a/net/ipv6/netfilter/ip6table_security.c	2009-01-26 17:24:43.735541493 -0800
+++ b/net/ipv6/netfilter/ip6table_security.c	2009-01-26 19:50:37.895044361 -0800
@@ -59,7 +59,6 @@ static struct
 static struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(security_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET6,
 };
--- a/net/ipv4/netfilter/iptable_mangle.c	2009-01-26 17:24:43.691541994 -0800
+++ b/net/ipv4/netfilter/iptable_mangle.c	2009-01-26 19:50:37.895044361 -0800
@@ -67,7 +67,6 @@ static struct
 static struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(packet_mangler.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };

-- 

