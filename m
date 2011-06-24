From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/20] tipc: Eliminate checks for empty zone list during name translation
Date: Fri, 24 Jun 2011 18:07:18 -0400
Message-ID: <1308953247-25266-12-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34390 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756994Ab1FXWHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:48 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of a pair of checks to see if a name sequence entry in
TIPC's name table has an empty zone list. These checks are pointless
since the zone list can never be empty (i.e. as soon as the list
becomes empty the associated name sequence entry is deleted).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 7d85cc1..46e6b6c 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -574,14 +574,13 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 						cluster_list);
 			list_move_tail(&publ->cluster_list,
 				       &info->cluster_list);
-		} else if (!list_empty(&info->zone_list)) {
+		} else {
 			publ = list_first_entry(&info->zone_list,
 						struct publication,
 						zone_list);
 			list_move_tail(&publ->zone_list,
 				       &info->zone_list);
-		} else
-			goto no_match;
+		}
 	}
 
 	/* Round-Robin Algorithm: */
@@ -598,8 +597,6 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 					cluster_list);
 		list_move_tail(&publ->cluster_list, &info->cluster_list);
 	} else {
-		if (list_empty(&info->zone_list))
-			goto no_match;
 		publ = list_first_entry(&info->zone_list, struct publication,
 					zone_list);
 		list_move_tail(&publ->zone_list, &info->zone_list);
-- 
1.7.4.4

