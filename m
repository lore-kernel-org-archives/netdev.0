From: Colin King <colin.king@canonical.com>
Subject: [PATCH] bpf: don't kfree an uninitialized im_node
Date: Tue, 24 Jan 2017 14:16:29 +0000
Message-ID: <20170124141629.9200-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

There are some error exit paths to the label 'out' that end up
kfree'ing an uninitialized im_node.  Fix this by inititializing
im_node to NULL to avoid kfree'ing a garbage address.

Issue found by CoverityScan, CID#1398022 ("Uninitialized pointer read")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
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
2.10.2
