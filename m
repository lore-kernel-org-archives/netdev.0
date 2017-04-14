From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] Add uid and cookie bpf helper to cg_skb_func_proto
Date: Fri, 14 Apr 2017 16:12:14 -0700
Message-ID: <1492211534-6363-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33991 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754731AbdDNXMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 19:12:23 -0400
Received: by mail-pf0-f194.google.com with SMTP id g23so2121713pfj.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 16:12:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

BPF helper functions get_socket_cookie and get_socket_uid can be
used for network traffic classifications, among others. Expose
them also to programs of type BPF_PROG_TYPE_CGROUP_SKB. As of
commit 8f917bba0042 ("bpf: pass sk to helper functions") the required
skb->sk function is available at both cgroup bpf ingress and egress
hooks.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 net/core/filter.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index ce2a19d..b6db9e330 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2769,6 +2769,10 @@ cg_skb_func_proto(enum bpf_func_id func_id)
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_get_socket_cookie:
+		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
-- 
2.7.4
