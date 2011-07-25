From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7] neigh: Do not set tbl->entry_size in ipv4/ipv6 neigh
 tables.
Date: Mon, 25 Jul 2011 03:01:28 -0700 (PDT)
Message-ID: <20110725.030128.1460147436708203536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab1GYKDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 06:03:31 -0400
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
index 5dc4f4e..e19a0e7 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -315,7 +315,6 @@ static u32 clip_hash(const void *pkey, const struct net_device *dev, __u32 rnd)
 
 static struct neigh_table clip_tbl = {
 	.family 	= AF_INET,
-	.entry_size 	= sizeof(struct neighbour)+sizeof(struct atmarp_entry),
 	.key_len 	= 4,
 	.hash 		= clip_hash,
 	.constructor 	= clip_constructor,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96a164a..43f0d15 100644
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
index 9da6e02..2582431 100644
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
1.7.6

