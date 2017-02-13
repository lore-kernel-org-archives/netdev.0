From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH] bpf: reduce compiler warnings by adding fallthrough comments
Date: Tue, 14 Feb 2017 00:02:35 +0100
Message-ID: <20170213230235.12677-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ast@kernel.org, daniel@iogearbox.net, brouer@redhat.com,
        dcb314@hotmail.com, jbacik@fb.com,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36435 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdBMXCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 18:02:50 -0500
Received: by mail-lf0-f48.google.com with SMTP id z134so58153246lff.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:02:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following warnings:

kernel/bpf/verifier.c: In function ‘may_access_direct_pkt_data’:
kernel/bpf/verifier.c:702:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
   if (t == BPF_WRITE)
      ^
kernel/bpf/verifier.c:704:2: note: here
  case BPF_PROG_TYPE_SCHED_CLS:
  ^~~~
kernel/bpf/verifier.c: In function ‘reg_set_min_max_inv’:
kernel/bpf/verifier.c:2057:23: warning: this statement may fall through [-Wimplicit-fallthrough=]
   true_reg->min_value = 0;
   ~~~~~~~~~~~~~~~~~~~~^~~
kernel/bpf/verifier.c:2058:2: note: here
  case BPF_JSGT:
  ^~~~
kernel/bpf/verifier.c:2068:23: warning: this statement may fall through [-Wimplicit-fallthrough=]
   true_reg->min_value = 0;
   ~~~~~~~~~~~~~~~~~~~~^~~
kernel/bpf/verifier.c:2069:2: note: here
  case BPF_JSGE:
  ^~~~
kernel/bpf/verifier.c: In function ‘reg_set_min_max’:
kernel/bpf/verifier.c:2009:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
   false_reg->min_value = 0;
   ~~~~~~~~~~~~~~~~~~~~~^~~
kernel/bpf/verifier.c:2010:2: note: here
  case BPF_JSGT:
  ^~~~
kernel/bpf/verifier.c:2019:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
   false_reg->min_value = 0;
   ~~~~~~~~~~~~~~~~~~~~~^~~
kernel/bpf/verifier.c:2020:2: note: here
  case BPF_JSGE:
  ^~~~

Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
Using gcc (GCC) 7.0.1 20170204 (Red Hat 7.0.1-0.6)

 kernel/bpf/verifier.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1a754e5d2695..d2bded2b250c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -701,6 +701,7 @@ static bool may_access_direct_pkt_data(struct bpf_verifier_env *env,
 		/* dst_input() and dst_output() can't write for now */
 		if (t == BPF_WRITE)
 			return false;
+		/* fallthrough */
 	case BPF_PROG_TYPE_SCHED_CLS:
 	case BPF_PROG_TYPE_SCHED_ACT:
 	case BPF_PROG_TYPE_XDP:
@@ -2007,6 +2008,7 @@ static void reg_set_min_max(struct bpf_reg_state *true_reg,
 	case BPF_JGT:
 		/* Unsigned comparison, the minimum value is 0. */
 		false_reg->min_value = 0;
+		/* fallthrough */
 	case BPF_JSGT:
 		/* If this is false then we know the maximum val is val,
 		 * otherwise we know the min val is val+1.
@@ -2017,6 +2019,7 @@ static void reg_set_min_max(struct bpf_reg_state *true_reg,
 	case BPF_JGE:
 		/* Unsigned comparison, the minimum value is 0. */
 		false_reg->min_value = 0;
+		/* fallthrough */
 	case BPF_JSGE:
 		/* If this is false then we know the maximum value is val - 1,
 		 * otherwise we know the mimimum value is val.
@@ -2055,6 +2058,7 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 	case BPF_JGT:
 		/* Unsigned comparison, the minimum value is 0. */
 		true_reg->min_value = 0;
+		/* fallthrough */
 	case BPF_JSGT:
 		/*
 		 * If this is false, then the val is <= the register, if it is
@@ -2066,6 +2070,7 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 	case BPF_JGE:
 		/* Unsigned comparison, the minimum value is 0. */
 		true_reg->min_value = 0;
+		/* fallthrough */
 	case BPF_JSGE:
 		/* If this is false then constant < register, if it is true then
 		 * the register < constant.
-- 
2.11.1
