From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 2/4] net: make seq_operations const
Date: Mon, 12 Mar 2007 14:08:19 -0700
Message-ID: <20070312210907.658532320@linux-foundation.org>
References: <20070312210817.485320783@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42390 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954AbXCLVJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 17:09:33 -0400
Content-Disposition: inline; filename=net-seq-ops-const.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The seq_file operations stuff can be marked constant to
get it out of dirty cache.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c       |    4 ++--
 net/core/dev_mcast.c |    2 +-
 net/core/neighbour.c |    2 +-
 net/core/sock.c      |    2 +-
 net/core/wireless.c  |    2 +-
 net/ipv4/arp.c       |    2 +-
 net/ipv4/fib_hash.c  |    2 +-
 net/ipv4/fib_trie.c  |    4 ++--
 net/ipv4/igmp.c      |    4 ++--
 net/ipv4/ipmr.c      |    4 ++--
 net/ipv4/raw.c       |    2 +-
 net/ipv4/route.c     |    4 ++--
 12 files changed, 17 insertions(+), 17 deletions(-)

--- net-2.6.22.orig/net/core/dev.c	2007-03-12 12:29:38.000000000 -0700
+++ net-2.6.22/net/core/dev.c	2007-03-12 12:29:39.000000000 -0700
@@ -2177,7 +2177,7 @@
 	return 0;
 }
 
-static struct seq_operations dev_seq_ops = {
+static const struct seq_operations dev_seq_ops = {
 	.start = dev_seq_start,
 	.next  = dev_seq_next,
 	.stop  = dev_seq_stop,
@@ -2197,7 +2197,7 @@
 	.release = seq_release,
 };
 
-static struct seq_operations softnet_seq_ops = {
+static const struct seq_operations softnet_seq_ops = {
 	.start = softnet_seq_start,
 	.next  = softnet_seq_next,
 	.stop  = softnet_seq_stop,
--- net-2.6.22.orig/net/core/dev_mcast.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/core/dev_mcast.c	2007-03-12 12:29:39.000000000 -0700
@@ -264,7 +264,7 @@
 	return 0;
 }
 
-static struct seq_operations dev_mc_seq_ops = {
+static const struct seq_operations dev_mc_seq_ops = {
 	.start = dev_mc_seq_start,
 	.next  = dev_mc_seq_next,
 	.stop  = dev_mc_seq_stop,
--- net-2.6.22.orig/net/core/neighbour.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/core/neighbour.c	2007-03-12 12:29:39.000000000 -0700
@@ -2384,7 +2384,7 @@
 	return 0;
 }
 
-static struct seq_operations neigh_stat_seq_ops = {
+static const struct seq_operations neigh_stat_seq_ops = {
 	.start	= neigh_stat_seq_start,
 	.next	= neigh_stat_seq_next,
 	.stop	= neigh_stat_seq_stop,
--- net-2.6.22.orig/net/core/sock.c	2007-03-12 12:05:58.000000000 -0700
+++ net-2.6.22/net/core/sock.c	2007-03-12 12:29:39.000000000 -0700
@@ -1925,7 +1925,7 @@
 	return 0;
 }
 
-static struct seq_operations proto_seq_ops = {
+static const struct seq_operations proto_seq_ops = {
 	.start  = proto_seq_start,
 	.next   = proto_seq_next,
 	.stop   = proto_seq_stop,
--- net-2.6.22.orig/net/core/wireless.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/core/wireless.c	2007-03-12 12:29:39.000000000 -0700
@@ -660,7 +660,7 @@
 	return 0;
 }
 
-static struct seq_operations wireless_seq_ops = {
+static const struct seq_operations wireless_seq_ops = {
 	.start = dev_seq_start,
 	.next  = dev_seq_next,
 	.stop  = dev_seq_stop,
--- net-2.6.22.orig/net/ipv4/arp.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/ipv4/arp.c	2007-03-12 12:29:39.000000000 -0700
@@ -1360,7 +1360,7 @@
 
 /* ------------------------------------------------------------------------ */
 
-static struct seq_operations arp_seq_ops = {
+static const struct seq_operations arp_seq_ops = {
 	.start  = arp_seq_start,
 	.next   = neigh_seq_next,
 	.stop   = neigh_seq_stop,
--- net-2.6.22.orig/net/ipv4/fib_hash.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/ipv4/fib_hash.c	2007-03-12 12:29:39.000000000 -0700
@@ -1027,7 +1027,7 @@
 	return 0;
 }
 
-static struct seq_operations fib_seq_ops = {
+static const struct seq_operations fib_seq_ops = {
 	.start  = fib_seq_start,
 	.next   = fib_seq_next,
 	.stop   = fib_seq_stop,
--- net-2.6.22.orig/net/ipv4/fib_trie.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/ipv4/fib_trie.c	2007-03-12 12:29:39.000000000 -0700
@@ -2332,7 +2332,7 @@
 	return 0;
 }
 
-static struct seq_operations fib_trie_seq_ops = {
+static const struct seq_operations fib_trie_seq_ops = {
 	.start  = fib_trie_seq_start,
 	.next   = fib_trie_seq_next,
 	.stop   = fib_trie_seq_stop,
@@ -2453,7 +2453,7 @@
 	return 0;
 }
 
-static struct seq_operations fib_route_seq_ops = {
+static const struct seq_operations fib_route_seq_ops = {
 	.start  = fib_trie_seq_start,
 	.next   = fib_trie_seq_next,
 	.stop   = fib_trie_seq_stop,
--- net-2.6.22.orig/net/ipv4/igmp.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/ipv4/igmp.c	2007-03-12 12:29:39.000000000 -0700
@@ -2397,7 +2397,7 @@
 	return 0;
 }
 
-static struct seq_operations igmp_mc_seq_ops = {
+static const struct seq_operations igmp_mc_seq_ops = {
 	.start	=	igmp_mc_seq_start,
 	.next	=	igmp_mc_seq_next,
 	.stop	=	igmp_mc_seq_stop,
@@ -2571,7 +2571,7 @@
 	return 0;
 }
 
-static struct seq_operations igmp_mcf_seq_ops = {
+static const struct seq_operations igmp_mcf_seq_ops = {
 	.start	=	igmp_mcf_seq_start,
 	.next	=	igmp_mcf_seq_next,
 	.stop	=	igmp_mcf_seq_stop,
--- net-2.6.22.orig/net/ipv4/ipmr.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/ipv4/ipmr.c	2007-03-12 12:29:39.000000000 -0700
@@ -1677,7 +1677,7 @@
 	return 0;
 }
 
-static struct seq_operations ipmr_vif_seq_ops = {
+static const struct seq_operations ipmr_vif_seq_ops = {
 	.start = ipmr_vif_seq_start,
 	.next  = ipmr_vif_seq_next,
 	.stop  = ipmr_vif_seq_stop,
@@ -1840,7 +1840,7 @@
 	return 0;
 }
 
-static struct seq_operations ipmr_mfc_seq_ops = {
+static const struct seq_operations ipmr_mfc_seq_ops = {
 	.start = ipmr_mfc_seq_start,
 	.next  = ipmr_mfc_seq_next,
 	.stop  = ipmr_mfc_seq_stop,
--- net-2.6.22.orig/net/ipv4/raw.c	2007-03-12 12:05:34.000000000 -0700
+++ net-2.6.22/net/ipv4/raw.c	2007-03-12 12:29:39.000000000 -0700
@@ -887,7 +887,7 @@
 	return 0;
 }
 
-static struct seq_operations raw_seq_ops = {
+static const struct seq_operations raw_seq_ops = {
 	.start = raw_seq_start,
 	.next  = raw_seq_next,
 	.stop  = raw_seq_stop,
--- net-2.6.22.orig/net/ipv4/route.c	2007-03-12 12:05:58.000000000 -0700
+++ net-2.6.22/net/ipv4/route.c	2007-03-12 12:29:39.000000000 -0700
@@ -364,7 +364,7 @@
 	return 0;
 }
 
-static struct seq_operations rt_cache_seq_ops = {
+static const struct seq_operations rt_cache_seq_ops = {
 	.start  = rt_cache_seq_start,
 	.next   = rt_cache_seq_next,
 	.stop   = rt_cache_seq_stop,
@@ -470,7 +470,7 @@
 	return 0;
 }
 
-static struct seq_operations rt_cpu_seq_ops = {
+static const struct seq_operations rt_cpu_seq_ops = {
 	.start  = rt_cpu_seq_start,
 	.next   = rt_cpu_seq_next,
 	.stop   = rt_cpu_seq_stop,

--
Stephen Hemminger <shemminger@linux-foundation.org>

