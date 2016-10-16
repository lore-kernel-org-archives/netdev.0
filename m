From: Eric Leblond <eric@regit.org>
Subject: [PATCH 4/8] tools lib bpf: export function to set type
Date: Sun, 16 Oct 2016 23:18:30 +0200
Message-ID: <20161016211834.11732-5-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45260 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757178AbcJPVVR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:17 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current API was not allowing the user to set a type like socket
filter. To avoid a setter function for each type, the patch simply
exports a set function that takes the type in parameter.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/libbpf.c | 19 +++++++++----------
 tools/lib/bpf/libbpf.h |  3 +++
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 90932f1..7cd341e 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1336,26 +1336,25 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n)
 	return fd;
 }
 
-static void bpf_program__set_type(struct bpf_program *prog,
-				  enum bpf_prog_type type)
+int bpf_program__set_type(struct bpf_program *prog, unsigned int type)
 {
+	if (!prog)
+		return -EINVAL;
+	if (type >= __MAX_BPF_PROG_TYPE)
+		return -EINVAL;
+
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
index e40c8d3..a18783b 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -173,6 +173,9 @@ int bpf_program__set_kprobe(struct bpf_program *prog);
 bool bpf_program__is_tracepoint(struct bpf_program *prog);
 bool bpf_program__is_kprobe(struct bpf_program *prog);
 
+int bpf_program__set_type(struct bpf_program *prog,
+				  unsigned int type);
+
 /*
  * We don't need __attribute__((packed)) now since it is
  * unnecessary for 'bpf_map_def' because they are all aligned.
-- 
2.9.3
