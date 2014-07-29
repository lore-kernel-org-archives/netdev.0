From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2 v2 net-next] netfilter: xt_bpf: add mising opaque struct sk_filter definition
Date: Tue, 29 Jul 2014 18:12:15 +0200
Message-ID: <1406650335-5916-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@plumgrid.com,
	keescook@chromium.org, willemb@google.com, dborkman@redhat.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57091 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753827AbaG2QNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 12:13:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure is not exposed to userspace, so fix this by defining
struct sk_filter; so we skip the casting in kernelspace. This is safe
since userspace has no way to lurk with that internal pointer.

Fixes: e6f30c7 ("netfilter: x_tables: add xt_bpf match")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
v2: address Willem's feedback, we still need uapi/linux/filter.h for
    userspace iptables builds.

 include/uapi/linux/netfilter/xt_bpf.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
index 5dda450..2ec9fbc 100644
--- a/include/uapi/linux/netfilter/xt_bpf.h
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -6,6 +6,8 @@
 
 #define XT_BPF_MAX_NUM_INSTR	64
 
+struct sk_filter;
+
 struct xt_bpf_info {
 	__u16 bpf_program_num_elem;
 	struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];
-- 
1.7.10.4
