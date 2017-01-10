From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] bpf: Remove unused but set variable in __bpf_lru_list_shrink_inactive()
Date: Tue, 10 Jan 2017 15:02:07 +0100
Message-ID: <20170110140207.26480-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ast@kernel.org, Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:40088 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934634AbdAJOCN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 09:02:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variable 'first_node' in
__bpf_lru_list_shrink_inactive() to fix the following GCC warning when
building with 'W=1':

  kernel/bpf/bpf_lru_list.c:216:41: warning: variable ‘first_node’ set but not used [-Wunused-but-set-variable]

Cc: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 kernel/bpf/bpf_lru_list.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index 89b7ef41c86b..d78501ee0609 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -213,11 +213,10 @@ __bpf_lru_list_shrink_inactive(struct bpf_lru *lru,
 			       enum bpf_lru_list_type tgt_free_type)
 {
 	struct list_head *inactive = &l->lists[BPF_LRU_LIST_T_INACTIVE];
-	struct bpf_lru_node *node, *tmp_node, *first_node;
+	struct bpf_lru_node *node, *tmp_node;
 	unsigned int nshrinked = 0;
 	unsigned int i = 0;
 
-	first_node = list_first_entry(inactive, struct bpf_lru_node, list);
 	list_for_each_entry_safe_reverse(node, tmp_node, inactive, list) {
 		if (bpf_lru_node_is_ref(node)) {
 			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_ACTIVE);
-- 
2.11.0
