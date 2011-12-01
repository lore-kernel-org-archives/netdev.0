From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7] neigh: Do not set tbl->entry_size in ipv4/ipv6 neigh
 tables.
Date: Wed, 30 Nov 2011 22:41:43 -0500 (EST)
Message-ID: <20111130.224143.1833704595632399614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab1LADlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:45 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fhJI027333
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:44 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Let the core self-size the neigh entry based upon the key length.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/atm/clip.c   |    1 -
 net/ipv4/arp.c   |    1 -
 net/ipv6/ndisc.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index aea7cad..b1c7ada 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -322,7 +322,6 @@ static u32 clip_hash(const void *pkey, const struct net_device *dev, __u32 rnd)
 
 static struct neigh_table clip_tbl = {
 	.family 	= AF_INET,
-	.entry_size 	= sizeof(struct neighbour)+sizeof(struct atmarp_entry),
 	.key_len 	= 4,
 	.hash 		= clip_hash,
 	.constructor 	= clip_constructor,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 5c29ac5..fd4b3e8 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -164,7 +164,6 @@ static const struct neigh_ops arp_broken_ops = {
 
 struct neigh_table arp_tbl = {
 	.family		= AF_INET,
-	.entry_size	= sizeof(struct neighbour) + 4,
 	.key_len	= 4,
 	.hash		= arp_hash,
 	.constructor	= arp_constructor,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2854705..cfb9709 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -126,7 +126,6 @@ static const struct neigh_ops ndisc_direct_ops = {
 
 struct neigh_table nd_tbl = {
 	.family =	AF_INET6,
-	.entry_size =	sizeof(struct neighbour) + sizeof(struct in6_addr),
 	.key_len =	sizeof(struct in6_addr),
 	.hash =		ndisc_hash,
 	.constructor =	ndisc_constructor,
-- 
1.7.6.4
