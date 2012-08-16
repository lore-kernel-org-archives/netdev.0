From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 6/9] tipc: convert tipc_nametbl_size type from variable to macro
Date: Thu, 16 Aug 2012 18:09:11 -0400
Message-ID: <1345154954-12526-7-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57501 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911Ab2HPWOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:52 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

There is nothing changing this variable dynamically, so change
it to a macro to make that more obvious when reading the code.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 360c478..4ebdcc9 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -41,7 +41,7 @@
 #include "subscr.h"
 #include "port.h"
 
-static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
+#define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
 /**
  * struct name_info - name sequence publication info
@@ -114,7 +114,7 @@ DEFINE_RWLOCK(tipc_nametbl_lock);
 
 static int hash(int x)
 {
-	return x & (tipc_nametbl_size - 1);
+	return x & (TIPC_NAMETBL_SIZE - 1);
 }
 
 /**
@@ -871,7 +871,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		ret += nametbl_header(buf, len, depth);
 		lowbound = 0;
 		upbound = ~0;
-		for (i = 0; i < tipc_nametbl_size; i++) {
+		for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
 			seq_head = &table.types[i];
 			hlist_for_each_entry(seq, seq_node, seq_head, ns_list) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
@@ -935,7 +935,7 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 
 int tipc_nametbl_init(void)
 {
-	table.types = kcalloc(tipc_nametbl_size, sizeof(struct hlist_head),
+	table.types = kcalloc(TIPC_NAMETBL_SIZE, sizeof(struct hlist_head),
 			      GFP_ATOMIC);
 	if (!table.types)
 		return -ENOMEM;
@@ -953,7 +953,7 @@ void tipc_nametbl_stop(void)
 
 	/* Verify name table is empty, then release it */
 	write_lock_bh(&tipc_nametbl_lock);
-	for (i = 0; i < tipc_nametbl_size; i++) {
+	for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
 		if (hlist_empty(&table.types[i]))
 			continue;
 		pr_err("nametbl_stop(): orphaned hash chain detected\n");
-- 
1.7.11.1
