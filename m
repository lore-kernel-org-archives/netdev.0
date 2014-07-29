From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next 1/2] netfilter: xt_bpf: don't include linux/filter.h from uapi header
Date: Tue, 29 Jul 2014 17:36:27 +0200
Message-ID: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@plumgrid.com,
	dborkman@redhat.com, willemb@google.com, keescook@chromium.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52290 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752446AbaG2PhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 11:37:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In e6f30c7 ("netfilter: x_tables: add xt_bpf match"), the internal
linux/filter.h header slipped through in the user exposed xt_bpf.h
header as included file.

Fix this by defining struct sk_filter; so we skip the casting in
kernelspace. This is safe since userspace has no way to lurk with
that internal pointer.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
@David: This patch is very small and it can probably go into net, but it's
        quite late for changes in -rc7 probably. Your call :-). Thanks.

 include/uapi/linux/netfilter/xt_bpf.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
index 5dda450..93fca65 100644
--- a/include/uapi/linux/netfilter/xt_bpf.h
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -1,11 +1,12 @@
 #ifndef _XT_BPF_H
 #define _XT_BPF_H
 
-#include <linux/filter.h>
 #include <linux/types.h>
 
 #define XT_BPF_MAX_NUM_INSTR	64
 
+struct sk_filter;
+
 struct xt_bpf_info {
 	__u16 bpf_program_num_elem;
 	struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];
-- 
1.7.10.4
