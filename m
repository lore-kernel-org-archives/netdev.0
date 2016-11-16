From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 4/4] bpf: add __must_check attributes to refcount manipulating helpers
Date: Wed, 16 Nov 2016 01:04:11 +0100
Message-ID: <3f3ec63df67e7f1adad92d0ea69ddfb31cebbf53.1479253024.git.daniel@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36577 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754039AbcKPAEX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:04:23 -0500
In-Reply-To: <cover.1479253024.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479253024.git.daniel@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Helpers like bpf_prog_add(), bpf_prog_inc(), bpf_map_inc() can fail
with an error, so make sure the caller properly checks their return
value and not just ignores it (which could worst-case lead to use
after free).

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 01c1487..69d0a7f 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -233,14 +233,14 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
-struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i);
+struct bpf_prog * __must_check bpf_prog_add(struct bpf_prog *prog, int i);
 void bpf_prog_sub(struct bpf_prog *prog, int i);
-struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog);
+struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
 
 struct bpf_map *bpf_map_get_with_uref(u32 ufd);
 struct bpf_map *__bpf_map_get(struct fd f);
-struct bpf_map *bpf_map_inc(struct bpf_map *map, bool uref);
+struct bpf_map * __must_check bpf_map_inc(struct bpf_map *map, bool uref);
 void bpf_map_put_with_uref(struct bpf_map *map);
 void bpf_map_put(struct bpf_map *map);
 int bpf_map_precharge_memlock(u32 pages);
@@ -299,7 +299,8 @@ static inline struct bpf_prog *bpf_prog_get_type(u32 ufd,
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
-static inline struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
+static inline struct bpf_prog * __must_check bpf_prog_add(struct bpf_prog *prog,
+							  int i)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
@@ -311,7 +312,8 @@ static inline void bpf_prog_sub(struct bpf_prog *prog, int i)
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
-static inline struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
+
+static inline struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
-- 
1.9.3
