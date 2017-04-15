From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v2] Add uid and cookie bpf helper to cg_skb_func_proto
Date: Fri, 14 Apr 2017 18:25:26 -0700
Message-ID: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34097 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdDOBZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 21:25:35 -0400
Received: by mail-pg0-f68.google.com with SMTP id o123so18406692pga.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 18:25:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

BPF helper functions get_socket_cookie and get_socket_uid can be
used for network traffic classifications, among others. Expose
them also to programs of type BPF_PROG_TYPE_CGROUP_SKB. As of
commit 8f917bba0042 ("bpf: pass sk to helper functions") the
required skb->sk function is available at both cgroup bpf ingress
and egress hooks. With these two new helper, cg_skb_func_proto is
effectively the same as sk_filter_func_proto.

Change since V1:
Instead of add the helper to cg_skb_func_proto, redirect the
cg_skb_func_proto to sk_filter_func_proto since all helper function
in sk_filter_func_proto are applicable to cg_skb_func_proto now.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 net/core/filter.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index ce2a19d..19be954 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2766,12 +2766,7 @@ xdp_func_proto(enum bpf_func_id func_id)
 static const struct bpf_func_proto *
 cg_skb_func_proto(enum bpf_func_id func_id)
 {
-	switch (func_id) {
-	case BPF_FUNC_skb_load_bytes:
-		return &bpf_skb_load_bytes_proto;
-	default:
-		return bpf_base_func_proto(func_id);
-	}
+	return sk_filter_func_proto(func_id);
 }
 
 static const struct bpf_func_proto *
-- 
2.7.4
