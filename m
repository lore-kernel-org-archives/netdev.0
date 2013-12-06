From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 6/6] tipc: separate the check nseq and sseq allocate failed
Date: Fri, 6 Dec 2013 14:23:42 +0800
Message-ID: <1386311022-11176-7-git-send-email-wangweidong1@huawei.com>
References: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45070 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab3LFGX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:23:59 -0500
In-Reply-To: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if nseq allocate failed, sseq is no need to alloc. so separate the
check.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/name_table.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 92a1533..b91387c 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -159,12 +159,17 @@ static struct sub_seq *tipc_subseq_alloc(u32 cnt)
 static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_head)
 {
 	struct name_seq *nseq = kzalloc(sizeof(*nseq), GFP_ATOMIC);
-	struct sub_seq *sseq = tipc_subseq_alloc(1);
+	struct sub_seq *sseq;
 
-	if (!nseq || !sseq) {
+	if (!nseq) {
 		pr_warn("Name sequence creation failed, no memory\n");
+		return NULL;
+	}
+
+	sseq = tipc_subseq_alloc(1);
+	if (!sseq) {
+		pr_warn("Sub sequence creation failed, no memory\n");
 		kfree(nseq);
-		kfree(sseq);
 		return NULL;
 	}
 
-- 
1.7.12
