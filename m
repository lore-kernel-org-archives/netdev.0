From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/16] tipc: Don't record failed publication attempt as a success
Date: Fri, 20 Apr 2012 17:05:13 -0400
Message-ID: <1334955924-907-6-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65447 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab2DTVFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:32 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

No longer increments counter of number of publications by a node
if an attempt to add a new publication fails. This prevents TIPC from
incorrectly blocking future publications because the configured maximum
number of publications has been reached.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index bd80d80..5d70042 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -695,11 +695,12 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	}
 
 	write_lock_bh(&tipc_nametbl_lock);
-	table.local_publ_count++;
 	publ = tipc_nametbl_insert_publ(type, lower, upper, scope,
 				   tipc_own_addr, port_ref, key);
-	if (likely(publ))
+	if (likely(publ)) {
+		table.local_publ_count++;
 		tipc_named_publish(publ);
+	}
 	write_unlock_bh(&tipc_nametbl_lock);
 	return publ;
 }
-- 
1.7.9.3
