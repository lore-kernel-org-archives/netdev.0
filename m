From: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
Subject: [PATCH net-next] tools: bpf: handle long path in jit disasm
Date: Thu,  2 Nov 2017 17:09:45 +0900
Message-ID: <20171102080945.7436-1-bhole_prashant_q7@lab.ntt.co.jp>
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:43574 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933120AbdKBILJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:11:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PATH_MAX instead of hardcoded array size 256

Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
---
 tools/bpf/bpf_jit_disasm.c     | 3 ++-
 tools/bpf/bpftool/jit_disasm.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/bpf/bpf_jit_disasm.c b/tools/bpf/bpf_jit_disasm.c
index 422d9abd666a..75bf526a0168 100644
--- a/tools/bpf/bpf_jit_disasm.c
+++ b/tools/bpf/bpf_jit_disasm.c
@@ -27,6 +27,7 @@
 #include <sys/klog.h>
 #include <sys/types.h>
 #include <sys/stat.h>
+#include <limits.h>
 
 #define CMD_ACTION_SIZE_BUFFER		10
 #define CMD_ACTION_READ_ALL		3
@@ -51,7 +52,7 @@ static void get_exec_path(char *tpath, size_t size)
 static void get_asm_insns(uint8_t *image, size_t len, int opcodes)
 {
 	int count, i, pc = 0;
-	char tpath[256];
+	char tpath[PATH_MAX];
 	struct disassemble_info info;
 	disassembler_ftype disassemble;
 	bfd *bfdf;
diff --git a/tools/bpf/bpftool/jit_disasm.c b/tools/bpf/bpftool/jit_disasm.c
index 5937e134e408..1551d3918d4c 100644
--- a/tools/bpf/bpftool/jit_disasm.c
+++ b/tools/bpf/bpftool/jit_disasm.c
@@ -21,6 +21,7 @@
 #include <dis-asm.h>
 #include <sys/types.h>
 #include <sys/stat.h>
+#include <limits.h>
 
 #include "json_writer.h"
 #include "main.h"
@@ -80,7 +81,7 @@ void disasm_print_insn(unsigned char *image, ssize_t len, int opcodes)
 	disassembler_ftype disassemble;
 	struct disassemble_info info;
 	int count, i, pc = 0;
-	char tpath[256];
+	char tpath[PATH_MAX];
 	bfd *bfdf;
 
 	if (!len)
-- 
2.13.5
