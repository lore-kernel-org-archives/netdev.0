From: sfeldma@gmail.com
Subject: [PATCH net-next 2/2] rocker: fix some sparse warnings
Date: Fri,  6 Mar 2015 01:14:37 -0800
Message-ID: <1425633277-32929-2-git-send-email-sfeldma@gmail.com>
References: <1425633277-32929-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:41947 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbCFJNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 04:13:53 -0500
Received: by pablj1 with SMTP id lj1so43898120pab.8
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 01:13:52 -0800 (PST)
In-Reply-To: <1425633277-32929-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d04d3b3..cc1bbfd 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2737,7 +2737,7 @@ static struct rocker_neigh_tbl_entry *
 {
 	struct rocker_neigh_tbl_entry *found;
 
-	hash_for_each_possible(rocker->neigh_tbl, found, entry, ip_addr)
+	hash_for_each_possible(rocker->neigh_tbl, found, entry, (u32)ip_addr)
 		if (found->ip_addr == ip_addr)
 			return found;
 
@@ -2749,7 +2749,7 @@ static void _rocker_neigh_add(struct rocker *rocker,
 {
 	entry->index = rocker->neigh_tbl_next_index++;
 	entry->ref_count++;
-	hash_add(rocker->neigh_tbl, &entry->entry, entry->ip_addr);
+	hash_add(rocker->neigh_tbl, &entry->entry, (u32)entry->ip_addr);
 }
 
 static void _rocker_neigh_del(struct rocker *rocker,
@@ -2868,7 +2868,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 				    __be32 ip_addr)
 {
 	struct net_device *dev = rocker_port->dev;
-	struct neighbour *n = __ipv4_neigh_lookup(dev, ip_addr);
+	struct neighbour *n = __ipv4_neigh_lookup(dev, (u32)ip_addr);
 	int err = 0;
 
 	if (!n)
-- 
1.7.10.4
