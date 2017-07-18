From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: fix build error in devmap helper calls
Date: Mon, 17 Jul 2017 21:56:48 -0700
Message-ID: <20170718045648.7398.68557.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33022 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdGRE5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 00:57:02 -0400
Received: by mail-pf0-f194.google.com with SMTP id e199so1318233pfh.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 21:57:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial patches missed case with CONFIG_BPF_SYSCALL not set.

Fixes: 11393cc9b9be ("xdp: Add batching support to redirect map")
Fixes: 97f91a7cf04f ("bpf: add bpf_redirect_map helper routine")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/linux/bpf.h |   25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 6850a76..6353c74 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -318,6 +318,12 @@ static inline void bpf_long_memcpy(void *dst, const void *src, u32 size)
 
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
+
+/* Map specifics */
+struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
+void __dev_map_insert_ctx(struct bpf_map *map, u32 index);
+void __dev_map_flush(struct bpf_map *map);
+
 #else
 static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 {
@@ -356,6 +362,20 @@ static inline int __bpf_prog_charge(struct user_struct *user, u32 pages)
 static inline void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
 {
 }
+
+static inline struct net_device  *__dev_map_lookup_elem(struct bpf_map *map,
+						       u32 key)
+{
+	return NULL;
+}
+
+static inline void __dev_map_insert_ctx(struct bpf_map *map, u32 index)
+{
+}
+
+static inline void __dev_map_flush(struct bpf_map *map)
+{
+}
 #endif /* CONFIG_BPF_SYSCALL */
 
 /* verifier prototypes for helper functions called from eBPF programs */
@@ -379,9 +399,4 @@ static inline void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
-/* Map specifics */
-struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
-void __dev_map_insert_ctx(struct bpf_map *map, u32 index);
-void __dev_map_flush(struct bpf_map *map);
-
 #endif /* _LINUX_BPF_H */
