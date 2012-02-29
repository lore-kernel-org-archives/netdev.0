From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/17] tipc: Add check to prevent insertion of duplicate name table entries
Date: Wed, 29 Feb 2012 18:18:31 -0500
Message-ID: <1330557523-2024-6-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53947 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965232Ab2B2XTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:00 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds a new check to TIPC's name table logic to reject any attempt to
create a new name publication that is identical to an existing one.
(Such an attempt will never happen under normal circumstances, but
could arise if another network node malfunctions and issues a duplicate
name publication message.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 1196f05..c2224f9 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -268,6 +268,13 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		}
 
 		info = sseq->info;
+
+		/* Check if an identical publication already exists */
+		list_for_each_entry(publ, &info->zone_list, zone_list) {
+			if ((publ->ref == port) && (publ->key == key) &&
+			    (!publ->node || (publ->node == node)))
+				return NULL;
+		}
 	} else {
 		u32 inspos;
 		struct sub_seq *freesseq;
-- 
1.7.9.1
