From: sfeldma@gmail.com
Subject: [PATCH net-next 1/2] rocker: quiet sparce endianess warnings
Date: Fri,  6 Mar 2015 15:54:51 -0800
Message-ID: <1425686092-2836-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36011 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbbCFXx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 18:53:57 -0500
Received: by padfa1 with SMTP id fa1so49228964pad.3
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 15:53:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index cc1bbfd..9629352 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2737,7 +2737,8 @@ static struct rocker_neigh_tbl_entry *
 {
 	struct rocker_neigh_tbl_entry *found;
 
-	hash_for_each_possible(rocker->neigh_tbl, found, entry, (u32)ip_addr)
+	hash_for_each_possible(rocker->neigh_tbl, found,
+			       entry, be32_to_cpu(ip_addr))
 		if (found->ip_addr == ip_addr)
 			return found;
 
@@ -2749,7 +2750,8 @@ static void _rocker_neigh_add(struct rocker *rocker,
 {
 	entry->index = rocker->neigh_tbl_next_index++;
 	entry->ref_count++;
-	hash_add(rocker->neigh_tbl, &entry->entry, (u32)entry->ip_addr);
+	hash_add(rocker->neigh_tbl, &entry->entry,
+		 be32_to_cpu(entry->ip_addr));
 }
 
 static void _rocker_neigh_del(struct rocker *rocker,
@@ -2868,7 +2870,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 				    __be32 ip_addr)
 {
 	struct net_device *dev = rocker_port->dev;
-	struct neighbour *n = __ipv4_neigh_lookup(dev, (u32)ip_addr);
+	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
 	int err = 0;
 
 	if (!n)
-- 
1.7.10.4
