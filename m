From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/7] ebpf: export BPF_PSEUDO_MAP_FD to uapi
Date: Wed, 11 Feb 2015 01:15:16 +0100
Message-ID: <2b58ccd3ab577142297a7995fda7a065e51abef8.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56178 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbBKAPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:36 -0500
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to export BPF_PSEUDO_MAP_FD to user space, as it's used in
the ELF BPF loader where instructions are being loaded that need
map fixups (relocations). An initial stage loads all maps into the
kernel, and later on replaces related instructions in the eBPF blob
with BPF_PSEUDO_MAP_FD as source register and the actual fd as
immediate value. The kernel verifier recognizes this keyword and
replaces the map fd with a real pointer internally.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h   | 2 --
 include/uapi/linux/bpf.h | 2 ++
 samples/bpf/libbpf.h     | 4 +++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index caac208..5e3863d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -145,8 +145,6 @@ struct bpf_prog_aux;
 		.off   = 0,					\
 		.imm   = ((__u64) (IMM)) >> 32 })
 
-#define BPF_PSEUDO_MAP_FD	1
-
 /* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
 #define BPF_LD_MAP_FD(DST, MAP_FD)				\
 	BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 45da7ec..0248180 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -120,6 +120,8 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
+#define BPF_PSEUDO_MAP_FD	1
+
 /* flags for BPF_MAP_UPDATE_ELEM command */
 #define BPF_ANY		0 /* create new element or update existing */
 #define BPF_NOEXIST	1 /* create new element if it didn't exist */
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 58c5fe1..a6bb7e9 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -92,7 +92,9 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 		.off   = 0,					\
 		.imm   = ((__u64) (IMM)) >> 32 })
 
-#define BPF_PSEUDO_MAP_FD	1
+#ifndef BPF_PSEUDO_MAP_FD
+# define BPF_PSEUDO_MAP_FD	1
+#endif
 
 /* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
 #define BPF_LD_MAP_FD(DST, MAP_FD)				\
-- 
1.9.3
