From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-next-2.6] [TIPC]: Enhancements to name table initialization
Date: Mon, 12 May 2008 16:33:03 -0400
Message-ID: <1210624383-2175-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58768 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751162AbYELUhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 16:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enhances the initialization of TIPC's name table
by removing a pointless spinlock operation, and by using
kcalloc() to detect requests for an oversized name table.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/name_table.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index ac7dfdd..892373e 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1050,15 +1050,12 @@ void tipc_nametbl_dump(void)
 
 int tipc_nametbl_init(void)
 {
-	int array_size = sizeof(struct hlist_head) * tipc_nametbl_size;
-
-	table.types = kzalloc(array_size, GFP_ATOMIC);
+	table.types = kcalloc(tipc_nametbl_size, sizeof(struct hlist_head),
+			      GFP_ATOMIC);
 	if (!table.types)
 		return -ENOMEM;
 
-	write_lock_bh(&tipc_nametbl_lock);
 	table.local_publ_count = 0;
-	write_unlock_bh(&tipc_nametbl_lock);
 	return 0;
 }
 
-- 
1.5.3.2

