From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] tipc: Delete error messages for failed memory allocations in
 three functions
Date: Tue, 23 May 2017 15:07:01 +0200
Message-ID: <7ac9d513-6f9f-a096-e68f-81a722c2723c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 23 May 2017 14:45:25 +0200

Omit four extra messages for memory allocation failures in these functions.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/tipc/name_table.c | 15 ++++-----------
 net/tipc/node.c       |  5 ++---
 2 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index bd0aac87b41a..7e731af8a1a7 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -117,10 +117,8 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 				       u32 key)
 {
 	struct publication *publ = kzalloc(sizeof(*publ), GFP_ATOMIC);
-	if (publ == NULL) {
-		pr_warn("Publication creation failure, no memory\n");
+	if (!publ)
 		return NULL;
-	}
 
 	publ->type = type;
 	publ->lower = lower;
@@ -270,11 +268,9 @@ static struct publication *tipc_nameseq_insert_publ(struct net *net,
 		if (nseq->first_free == nseq->alloc) {
 			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
 
-			if (!sseqs) {
-				pr_warn("Cannot publish {%u,%u,%u}, no memory\n",
-					type, lower, upper);
+			if (!sseqs)
 				return NULL;
-			}
+
 			memcpy(sseqs, nseq->sseqs,
 			       nseq->alloc * sizeof(struct sub_seq));
 			kfree(nseq->sseqs);
@@ -283,11 +279,8 @@ static struct publication *tipc_nameseq_insert_publ(struct net *net,
 		}
 
 		info = kzalloc(sizeof(*info), GFP_ATOMIC);
-		if (!info) {
-			pr_warn("Cannot publish {%u,%u,%u}, no memory\n",
-				type, lower, upper);
+		if (!info)
 			return NULL;
-		}
 
 		INIT_LIST_HEAD(&info->node_list);
 		INIT_LIST_HEAD(&info->cluster_list);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index aeef8011ac7d..0c7f5f755a28 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -324,10 +324,9 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr, u16 capabilities)
 		goto exit;
 	}
 	n = kzalloc(sizeof(*n), GFP_ATOMIC);
-	if (!n) {
-		pr_warn("Node creation failed, no memory\n");
+	if (!n)
 		goto exit;
-	}
+
 	n->addr = addr;
 	n->net = net;
 	n->capabilities = capabilities;
-- 
2.13.0
