From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, lpm: fix kfree of im_node in trie_update_elem
Date: Tue, 24 Jan 2017 01:26:46 +0100
Message-ID: <6052894aa1bd4df5a5c7aaa05f5b63a980cbe371.1485217298.git.daniel@iogearbox.net>
Cc: ast@kernel.org, daniel@zonque.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46513 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXA0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:26:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to initialize im_node to NULL, otherwise in case of error path
it gets passed to kfree() as uninitialized pointer.

Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 Mentioned it in http://patchwork.ozlabs.org/patch/718070/, but
 was probably overlooked.

 kernel/bpf/lpm_trie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index ba19241d..144e976 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -262,7 +262,7 @@ static int trie_update_elem(struct bpf_map *map,
 			    void *_key, void *value, u64 flags)
 {
 	struct lpm_trie *trie = container_of(map, struct lpm_trie, map);
-	struct lpm_trie_node *node, *im_node, *new_node = NULL;
+	struct lpm_trie_node *node, *im_node = NULL, *new_node = NULL;
 	struct lpm_trie_node __rcu **slot;
 	struct bpf_lpm_trie_key *key = _key;
 	unsigned long irq_flags;
-- 
1.9.3
