From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf: mark all registered map/prog types as __ro_after_init
Date: Thu, 16 Feb 2017 22:24:48 +0100
Message-ID: <1354bbba1ffa186d759309be2fe809e870a6b3c3.1487279499.git.daniel@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40157 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932975AbdBPVZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 16:25:37 -0500
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All map types and prog types are registered to the BPF core through
bpf_register_map_type() and bpf_register_prog_type() during init and
remain unchanged thereafter. As by design we don't (and never will)
have any pluggable code that can register to that at any later point
in time, lets mark all the existing bpf_{map,prog}_type_list objects
in the tree as __ro_after_init, so they can be moved to read-only
section from then onwards.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/arraymap.c    | 10 +++++-----
 kernel/bpf/hashtab.c     |  8 ++++----
 kernel/bpf/lpm_trie.c    |  2 +-
 kernel/bpf/stackmap.c    |  2 +-
 kernel/trace/bpf_trace.c |  6 +++---
 net/core/filter.c        | 18 +++++++++---------
 6 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 3d55d95..6b6f41f 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -269,7 +269,7 @@ static void array_map_free(struct bpf_map *map)
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list array_type __read_mostly = {
+static struct bpf_map_type_list array_type __ro_after_init = {
 	.ops = &array_ops,
 	.type = BPF_MAP_TYPE_ARRAY,
 };
@@ -283,7 +283,7 @@ static void array_map_free(struct bpf_map *map)
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list percpu_array_type __read_mostly = {
+static struct bpf_map_type_list percpu_array_type __ro_after_init = {
 	.ops = &percpu_array_ops,
 	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
 };
@@ -409,7 +409,7 @@ void bpf_fd_array_map_clear(struct bpf_map *map)
 	.map_fd_put_ptr = prog_fd_array_put_ptr,
 };
 
-static struct bpf_map_type_list prog_array_type __read_mostly = {
+static struct bpf_map_type_list prog_array_type __ro_after_init = {
 	.ops = &prog_array_ops,
 	.type = BPF_MAP_TYPE_PROG_ARRAY,
 };
@@ -522,7 +522,7 @@ static void perf_event_fd_array_release(struct bpf_map *map,
 	.map_release = perf_event_fd_array_release,
 };
 
-static struct bpf_map_type_list perf_event_array_type __read_mostly = {
+static struct bpf_map_type_list perf_event_array_type __ro_after_init = {
 	.ops = &perf_event_array_ops,
 	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
 };
@@ -564,7 +564,7 @@ static void cgroup_fd_array_free(struct bpf_map *map)
 	.map_fd_put_ptr = cgroup_fd_array_put_ptr,
 };
 
-static struct bpf_map_type_list cgroup_array_type __read_mostly = {
+static struct bpf_map_type_list cgroup_array_type __ro_after_init = {
 	.ops = &cgroup_array_ops,
 	.type = BPF_MAP_TYPE_CGROUP_ARRAY,
 };
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index a753bbe..3ea87fb 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -1023,7 +1023,7 @@ static void htab_map_free(struct bpf_map *map)
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_type __read_mostly = {
+static struct bpf_map_type_list htab_type __ro_after_init = {
 	.ops = &htab_ops,
 	.type = BPF_MAP_TYPE_HASH,
 };
@@ -1037,7 +1037,7 @@ static void htab_map_free(struct bpf_map *map)
 	.map_delete_elem = htab_lru_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_lru_type __read_mostly = {
+static struct bpf_map_type_list htab_lru_type __ro_after_init = {
 	.ops = &htab_lru_ops,
 	.type = BPF_MAP_TYPE_LRU_HASH,
 };
@@ -1124,7 +1124,7 @@ int bpf_percpu_hash_update(struct bpf_map *map, void *key, void *value,
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_percpu_type __read_mostly = {
+static struct bpf_map_type_list htab_percpu_type __ro_after_init = {
 	.ops = &htab_percpu_ops,
 	.type = BPF_MAP_TYPE_PERCPU_HASH,
 };
@@ -1138,7 +1138,7 @@ int bpf_percpu_hash_update(struct bpf_map *map, void *key, void *value,
 	.map_delete_elem = htab_lru_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_lru_percpu_type __read_mostly = {
+static struct bpf_map_type_list htab_lru_percpu_type __ro_after_init = {
 	.ops = &htab_lru_percpu_ops,
 	.type = BPF_MAP_TYPE_LRU_PERCPU_HASH,
 };
diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index e0f6a0b..8bfe0af 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -508,7 +508,7 @@ static void trie_free(struct bpf_map *map)
 	.map_delete_elem = trie_delete_elem,
 };
 
-static struct bpf_map_type_list trie_type __read_mostly = {
+static struct bpf_map_type_list trie_type __ro_after_init = {
 	.ops = &trie_ops,
 	.type = BPF_MAP_TYPE_LPM_TRIE,
 };
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index be85191..22aa45c 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -273,7 +273,7 @@ static void stack_map_free(struct bpf_map *map)
 	.map_delete_elem = stack_map_delete_elem,
 };
 
-static struct bpf_map_type_list stack_map_type __read_mostly = {
+static struct bpf_map_type_list stack_map_type __ro_after_init = {
 	.ops = &stack_map_ops,
 	.type = BPF_MAP_TYPE_STACK_TRACE,
 };
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 424daa4..cee9802 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -506,7 +506,7 @@ static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type
 	.is_valid_access = kprobe_prog_is_valid_access,
 };
 
-static struct bpf_prog_type_list kprobe_tl = {
+static struct bpf_prog_type_list kprobe_tl __ro_after_init = {
 	.ops	= &kprobe_prog_ops,
 	.type	= BPF_PROG_TYPE_KPROBE,
 };
@@ -589,7 +589,7 @@ static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type
 	.is_valid_access = tp_prog_is_valid_access,
 };
 
-static struct bpf_prog_type_list tracepoint_tl = {
+static struct bpf_prog_type_list tracepoint_tl __ro_after_init = {
 	.ops	= &tracepoint_prog_ops,
 	.type	= BPF_PROG_TYPE_TRACEPOINT,
 };
@@ -648,7 +648,7 @@ static u32 pe_prog_convert_ctx_access(enum bpf_access_type type,
 	.convert_ctx_access	= pe_prog_convert_ctx_access,
 };
 
-static struct bpf_prog_type_list perf_event_tl = {
+static struct bpf_prog_type_list perf_event_tl __ro_after_init = {
 	.ops	= &perf_event_prog_ops,
 	.type	= BPF_PROG_TYPE_PERF_EVENT,
 };
diff --git a/net/core/filter.c b/net/core/filter.c
index 0b753cb..e466e004 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3296,47 +3296,47 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
 
-static struct bpf_prog_type_list sk_filter_type __read_mostly = {
+static struct bpf_prog_type_list sk_filter_type __ro_after_init = {
 	.ops	= &sk_filter_ops,
 	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
-static struct bpf_prog_type_list sched_cls_type __read_mostly = {
+static struct bpf_prog_type_list sched_cls_type __ro_after_init = {
 	.ops	= &tc_cls_act_ops,
 	.type	= BPF_PROG_TYPE_SCHED_CLS,
 };
 
-static struct bpf_prog_type_list sched_act_type __read_mostly = {
+static struct bpf_prog_type_list sched_act_type __ro_after_init = {
 	.ops	= &tc_cls_act_ops,
 	.type	= BPF_PROG_TYPE_SCHED_ACT,
 };
 
-static struct bpf_prog_type_list xdp_type __read_mostly = {
+static struct bpf_prog_type_list xdp_type __ro_after_init = {
 	.ops	= &xdp_ops,
 	.type	= BPF_PROG_TYPE_XDP,
 };
 
-static struct bpf_prog_type_list cg_skb_type __read_mostly = {
+static struct bpf_prog_type_list cg_skb_type __ro_after_init = {
 	.ops	= &cg_skb_ops,
 	.type	= BPF_PROG_TYPE_CGROUP_SKB,
 };
 
-static struct bpf_prog_type_list lwt_in_type __read_mostly = {
+static struct bpf_prog_type_list lwt_in_type __ro_after_init = {
 	.ops	= &lwt_inout_ops,
 	.type	= BPF_PROG_TYPE_LWT_IN,
 };
 
-static struct bpf_prog_type_list lwt_out_type __read_mostly = {
+static struct bpf_prog_type_list lwt_out_type __ro_after_init = {
 	.ops	= &lwt_inout_ops,
 	.type	= BPF_PROG_TYPE_LWT_OUT,
 };
 
-static struct bpf_prog_type_list lwt_xmit_type __read_mostly = {
+static struct bpf_prog_type_list lwt_xmit_type __ro_after_init = {
 	.ops	= &lwt_xmit_ops,
 	.type	= BPF_PROG_TYPE_LWT_XMIT,
 };
 
-static struct bpf_prog_type_list cg_sock_type __read_mostly = {
+static struct bpf_prog_type_list cg_sock_type __ro_after_init = {
 	.ops	= &cg_sock_ops,
 	.type	= BPF_PROG_TYPE_CGROUP_SOCK
 };
-- 
1.9.3
