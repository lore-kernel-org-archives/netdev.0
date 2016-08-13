From: Eric Leblond <eric@regit.org>
Subject: [PATCH net-next 2/2] tools lib bpf: export function to set type
Date: Sat, 13 Aug 2016 14:17:23 +0200
Message-ID: <1471090643-22403-3-git-send-email-eric@regit.org>
References: <1471090643-22403-1-git-send-email-eric@regit.org>
Cc: Alexei Starovoitov <ast@fb.com>, wangnan0@huawei.com,
	Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:43863 "EHLO home.regit.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657AbcHMMjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2016 08:39:18 -0400
In-Reply-To: <1471090643-22403-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current API was not allowing the user to set a type like socket
filter. To avoid a setter function for each type, the patch simply
exports a set function that takes the type in parameter.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/libbpf.c | 15 ++++++---------
 tools/lib/bpf/libbpf.h |  3 +++
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 7872ff6..ff2a8c6 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1336,26 +1336,23 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n)
 	return fd;
 }
 
-static void bpf_program__set_type(struct bpf_program *prog,
+int bpf_program__set_type(struct bpf_program *prog,
 				  enum bpf_prog_type type)
 {
+	if (!prog)
+		return -EINVAL;
 	prog->type = type;
+	return 0;
 }
 
 int bpf_program__set_tracepoint(struct bpf_program *prog)
 {
-	if (!prog)
-		return -EINVAL;
-	bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
-	return 0;
+	return bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
 }
 
 int bpf_program__set_kprobe(struct bpf_program *prog)
 {
-	if (!prog)
-		return -EINVAL;
-	bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
-	return 0;
+	return bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
 }
 
 static bool bpf_program__is_type(struct bpf_program *prog,
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index a6c5cde..6a84d7a 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -173,6 +173,9 @@ int bpf_program__set_kprobe(struct bpf_program *prog);
 bool bpf_program__is_tracepoint(struct bpf_program *prog);
 bool bpf_program__is_kprobe(struct bpf_program *prog);
 
+int bpf_program__set_type(struct bpf_program *prog,
+				  enum bpf_prog_type type);
+
 /*
  * We don't need __attribute__((packed)) now since it is
  * unnecessary for 'bpf_map_def' because they are all aligned.
-- 
2.8.1
