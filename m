From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] bpf: check NULL for sk_to_full_sk() return value
Date: Mon, 17 Jul 2017 11:42:55 -0700
Message-ID: <20170717184255.6121-1-xiyou.wangcong@gmail.com>
Cc: dsahern@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Lawrence Brakmo <brakmo@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34732 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751312AbdGQSnI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 14:43:08 -0400
Received: by mail-pf0-f194.google.com with SMTP id o88so2324097pfk.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 11:43:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When req->rsk_listener is NULL, sk_to_full_sk() returns
NULL too, so we have to check its return value against
NULL here.

Fixes: 40304b2a1567 ("bpf: BPF support for sock_ops")
Reported-by: David Ahern <dsahern@gmail.com>
Tested-by: David Ahern <dsahern@gmail.com>
Cc: Lawrence Brakmo <brakmo@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/bpf-cgroup.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 360c082e885c..d41d40ac3efd 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -85,7 +85,7 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 	int __ret = 0;							       \
 	if (cgroup_bpf_enabled && (sock_ops)->sk) {	       \
 		typeof(sk) __sk = sk_to_full_sk((sock_ops)->sk);	       \
-		if (sk_fullsock(__sk))					       \
+		if (__sk && sk_fullsock(__sk))				       \
 			__ret = __cgroup_bpf_run_filter_sock_ops(__sk,	       \
 								 sock_ops,     \
 							 BPF_CGROUP_SOCK_OPS); \
-- 
2.13.0
