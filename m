From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 01/10] bpf: minor cleanups in ebpf code
Date: Fri, 13 May 2016 19:08:26 +0200
Message-ID: <b2c0888c352a066ff84d5a3f2516edc1babf079f.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41864 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbcEMRJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:01 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Besides others, remove redundant comments where the code is self
documenting enough, and properly indent various bpf_verifier_ops
and bpf_prog_type_list declarations. Moreover, remove two exports
that actually have no module user.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/core.c |  2 --
 net/core/filter.c | 34 +++++++++++++++-------------------
 2 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index d781b07..5313d09 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -129,14 +129,12 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 
 	return fp;
 }
-EXPORT_SYMBOL_GPL(bpf_prog_realloc);
 
 void __bpf_prog_free(struct bpf_prog *fp)
 {
 	kfree(fp->aux);
 	vfree(fp);
 }
-EXPORT_SYMBOL_GPL(__bpf_prog_free);
 
 #ifdef CONFIG_BPF_JIT
 struct bpf_binary_header *
diff --git a/net/core/filter.c b/net/core/filter.c
index 71c2a1f..ea51b47 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2069,16 +2069,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
-	/* check bounds */
 	if (off < 0 || off >= sizeof(struct __sk_buff))
 		return false;
-
-	/* disallow misaligned access */
+	/* The verifier guarantees that size > 0. */
 	if (off % size != 0)
 		return false;
-
-	/* all __sk_buff fields are __u32 */
-	if (size != 4)
+	if (size != sizeof(__u32))
 		return false;
 
 	return true;
@@ -2097,7 +2093,7 @@ static bool sk_filter_is_valid_access(int off, int size,
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case offsetof(struct __sk_buff, cb[0]) ...
-			offsetof(struct __sk_buff, cb[4]):
+		     offsetof(struct __sk_buff, cb[4]):
 			break;
 		default:
 			return false;
@@ -2278,30 +2274,30 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 }
 
 static const struct bpf_verifier_ops sk_filter_ops = {
-	.get_func_proto = sk_filter_func_proto,
-	.is_valid_access = sk_filter_is_valid_access,
-	.convert_ctx_access = bpf_net_convert_ctx_access,
+	.get_func_proto		= sk_filter_func_proto,
+	.is_valid_access	= sk_filter_is_valid_access,
+	.convert_ctx_access	= bpf_net_convert_ctx_access,
 };
 
 static const struct bpf_verifier_ops tc_cls_act_ops = {
-	.get_func_proto = tc_cls_act_func_proto,
-	.is_valid_access = tc_cls_act_is_valid_access,
-	.convert_ctx_access = bpf_net_convert_ctx_access,
+	.get_func_proto		= tc_cls_act_func_proto,
+	.is_valid_access	= tc_cls_act_is_valid_access,
+	.convert_ctx_access	= bpf_net_convert_ctx_access,
 };
 
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
-	.ops = &sk_filter_ops,
-	.type = BPF_PROG_TYPE_SOCKET_FILTER,
+	.ops	= &sk_filter_ops,
+	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
 static struct bpf_prog_type_list sched_cls_type __read_mostly = {
-	.ops = &tc_cls_act_ops,
-	.type = BPF_PROG_TYPE_SCHED_CLS,
+	.ops	= &tc_cls_act_ops,
+	.type	= BPF_PROG_TYPE_SCHED_CLS,
 };
 
 static struct bpf_prog_type_list sched_act_type __read_mostly = {
-	.ops = &tc_cls_act_ops,
-	.type = BPF_PROG_TYPE_SCHED_ACT,
+	.ops	= &tc_cls_act_ops,
+	.type	= BPF_PROG_TYPE_SCHED_ACT,
 };
 
 static int __init register_sk_filter_ops(void)
-- 
1.9.3
