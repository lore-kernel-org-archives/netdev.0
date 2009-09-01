From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: make neigh_ops constant
Date: Tue, 1 Sep 2009 14:13:19 -0700
Message-ID: <20090901141319.6ce685e9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53943 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbZIAVNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 17:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These tables are never modified at runtime. Move to read-only
section.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/arp.h       |    2 +-
 include/net/neighbour.h |    2 +-
 net/atm/clip.c          |    2 +-
 net/decnet/dn_neigh.c   |    6 +++---
 net/ipv4/arp.c          |    8 ++++----
 net/ipv6/ndisc.c        |    6 +++---
 6 files changed, 13 insertions(+), 13 deletions(-)

--- a/include/net/neighbour.h	2009-09-01 10:03:19.768820418 -0700
+++ b/include/net/neighbour.h	2009-09-01 10:43:34.777044929 -0700
@@ -118,7 +118,7 @@ struct neighbour
 	int			(*output)(struct sk_buff *skb);
 	struct sk_buff_head	arp_queue;
 	struct timer_list	timer;
-	struct neigh_ops	*ops;
+	const struct neigh_ops	*ops;
 	u8			primary_key[0];
 };
 
--- a/net/atm/clip.c	2009-09-01 10:03:19.738819943 -0700
+++ b/net/atm/clip.c	2009-09-01 10:03:40.185578062 -0700
@@ -267,7 +267,7 @@ static void clip_neigh_error(struct neig
 	kfree_skb(skb);
 }
 
-static struct neigh_ops clip_neigh_ops = {
+static const struct neigh_ops clip_neigh_ops = {
 	.family =		AF_INET,
 	.solicit =		clip_neigh_solicit,
 	.error_report =		clip_neigh_error,
--- a/net/decnet/dn_neigh.c	2009-09-01 10:03:19.744923430 -0700
+++ b/net/decnet/dn_neigh.c	2009-09-01 10:03:40.186548865 -0700
@@ -59,7 +59,7 @@ static int dn_phase3_output(struct sk_bu
 /*
  * For talking to broadcast devices: Ethernet & PPP
  */
-static struct neigh_ops dn_long_ops = {
+static const struct neigh_ops dn_long_ops = {
 	.family =		AF_DECnet,
 	.error_report =		dn_long_error_report,
 	.output =		dn_long_output,
@@ -71,7 +71,7 @@ static struct neigh_ops dn_long_ops = {
 /*
  * For talking to pointopoint and multidrop devices: DDCMP and X.25
  */
-static struct neigh_ops dn_short_ops = {
+static const struct neigh_ops dn_short_ops = {
 	.family =		AF_DECnet,
 	.error_report =		dn_short_error_report,
 	.output =		dn_short_output,
@@ -83,7 +83,7 @@ static struct neigh_ops dn_short_ops = {
 /*
  * For talking to DECnet phase III nodes
  */
-static struct neigh_ops dn_phase3_ops = {
+static const struct neigh_ops dn_phase3_ops = {
 	.family =		AF_DECnet,
 	.error_report =		dn_short_error_report, /* Can use short version here */
 	.output =		dn_phase3_output,
--- a/net/ipv4/arp.c	2009-09-01 10:03:19.756847564 -0700
+++ b/net/ipv4/arp.c	2009-09-01 10:38:38.791532681 -0700
@@ -130,7 +130,7 @@ static void arp_solicit(struct neighbour
 static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb);
 static void parp_redo(struct sk_buff *skb);
 
-static struct neigh_ops arp_generic_ops = {
+static const struct neigh_ops arp_generic_ops = {
 	.family =		AF_INET,
 	.solicit =		arp_solicit,
 	.error_report =		arp_error_report,
@@ -140,7 +140,7 @@ static struct neigh_ops arp_generic_ops 
 	.queue_xmit =		dev_queue_xmit,
 };
 
-static struct neigh_ops arp_hh_ops = {
+static const struct neigh_ops arp_hh_ops = {
 	.family =		AF_INET,
 	.solicit =		arp_solicit,
 	.error_report =		arp_error_report,
@@ -150,7 +150,7 @@ static struct neigh_ops arp_hh_ops = {
 	.queue_xmit =		dev_queue_xmit,
 };
 
-static struct neigh_ops arp_direct_ops = {
+static const struct neigh_ops arp_direct_ops = {
 	.family =		AF_INET,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
@@ -158,7 +158,7 @@ static struct neigh_ops arp_direct_ops =
 	.queue_xmit =		dev_queue_xmit,
 };
 
-struct neigh_ops arp_broken_ops = {
+const struct neigh_ops arp_broken_ops = {
 	.family =		AF_INET,
 	.solicit =		arp_solicit,
 	.error_report =		arp_error_report,
--- a/net/ipv6/ndisc.c	2009-09-01 10:03:19.750820837 -0700
+++ b/net/ipv6/ndisc.c	2009-09-01 10:03:40.192819983 -0700
@@ -98,7 +98,7 @@ static int pndisc_constructor(struct pne
 static void pndisc_destructor(struct pneigh_entry *n);
 static void pndisc_redo(struct sk_buff *skb);
 
-static struct neigh_ops ndisc_generic_ops = {
+static const struct neigh_ops ndisc_generic_ops = {
 	.family =		AF_INET6,
 	.solicit =		ndisc_solicit,
 	.error_report =		ndisc_error_report,
@@ -108,7 +108,7 @@ static struct neigh_ops ndisc_generic_op
 	.queue_xmit =		dev_queue_xmit,
 };
 
-static struct neigh_ops ndisc_hh_ops = {
+static const struct neigh_ops ndisc_hh_ops = {
 	.family =		AF_INET6,
 	.solicit =		ndisc_solicit,
 	.error_report =		ndisc_error_report,
@@ -119,7 +119,7 @@ static struct neigh_ops ndisc_hh_ops = {
 };
 
 
-static struct neigh_ops ndisc_direct_ops = {
+static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
--- a/include/net/arp.h	2009-09-01 10:38:14.812653889 -0700
+++ b/include/net/arp.h	2009-09-01 10:39:53.838862539 -0700
@@ -26,6 +26,6 @@ extern struct sk_buff *arp_create(int ty
 				  const unsigned char *target_hw);
 extern void arp_xmit(struct sk_buff *skb);
 
-extern struct neigh_ops arp_broken_ops;
+extern const struct neigh_ops arp_broken_ops;
 
 #endif	/* _ARP_H */
