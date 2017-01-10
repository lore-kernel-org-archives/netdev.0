From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] bpf: Make unnecessarily global functions static
Date: Tue, 10 Jan 2017 15:02:16 +0100
Message-ID: <20170110140216.26550-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ast@kernel.org, Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:40098 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934634AbdAJOCT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 09:02:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the functions __local_list_pop_free(), __local_list_pop_pending(),
bpf_common_lru_populate() and bpf_percpu_lru_populate() static as they
are not used outide of bpf_lru_list.c

This fixes the following GCC warnings when building with 'W=1':

  kernel/bpf/bpf_lru_list.c:363:22: warning: no previous prototype for ‘__local_list_pop_free’ [-Wmissing-prototypes]
  kernel/bpf/bpf_lru_list.c:376:22: warning: no previous prototype for ‘__local_list_pop_pending’ [-Wmissing-prototypes]
  kernel/bpf/bpf_lru_list.c:560:6: warning: no previous prototype for ‘bpf_common_lru_populate’ [-Wmissing-prototypes]
  kernel/bpf/bpf_lru_list.c:577:6: warning: no previous prototype for ‘bpf_percpu_lru_populate’ [-Wmissing-prototypes]

Cc: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 kernel/bpf/bpf_lru_list.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index d78501ee0609..f62d1d56f41d 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -360,7 +360,8 @@ static void __local_list_add_pending(struct bpf_lru *lru,
 	list_add(&node->list, local_pending_list(loc_l));
 }
 
-struct bpf_lru_node *__local_list_pop_free(struct bpf_lru_locallist *loc_l)
+static struct bpf_lru_node *
+__local_list_pop_free(struct bpf_lru_locallist *loc_l)
 {
 	struct bpf_lru_node *node;
 
@@ -373,8 +374,8 @@ struct bpf_lru_node *__local_list_pop_free(struct bpf_lru_locallist *loc_l)
 	return node;
 }
 
-struct bpf_lru_node *__local_list_pop_pending(struct bpf_lru *lru,
-					      struct bpf_lru_locallist *loc_l)
+static struct bpf_lru_node *
+__local_list_pop_pending(struct bpf_lru *lru, struct bpf_lru_locallist *loc_l)
 {
 	struct bpf_lru_node *node;
 	bool force = false;
@@ -557,8 +558,9 @@ void bpf_lru_push_free(struct bpf_lru *lru, struct bpf_lru_node *node)
 		bpf_common_lru_push_free(lru, node);
 }
 
-void bpf_common_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
-			     u32 elem_size, u32 nr_elems)
+static void bpf_common_lru_populate(struct bpf_lru *lru, void *buf,
+				    u32 node_offset, u32 elem_size,
+				    u32 nr_elems)
 {
 	struct bpf_lru_list *l = &lru->common_lru.lru_list;
 	u32 i;
@@ -574,8 +576,9 @@ void bpf_common_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
 	}
 }
 
-void bpf_percpu_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
-			     u32 elem_size, u32 nr_elems)
+static void bpf_percpu_lru_populate(struct bpf_lru *lru, void *buf,
+				    u32 node_offset, u32 elem_size,
+				    u32 nr_elems)
 {
 	u32 i, pcpu_entries;
 	int cpu;
-- 
2.11.0
