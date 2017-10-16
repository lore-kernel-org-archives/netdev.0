From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] tools: bpftool: use more common tag format
Date: Mon, 16 Oct 2017 10:12:54 -0700
Message-ID: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:43569 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdJPRNJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 13:13:09 -0400
Received: by mail-pg0-f54.google.com with SMTP id s75so6471583pgs.0
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 10:13:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Program tag is usually displayed as string of bytes without
any separators (e.g. as "aa5520b1090cfeb6" vs MAC addr-like
format bpftool uses currently: "aa:55:20:b1:09:0c:fe:b6").
Make bptfool use the more common format both for displaying
the tag and selecting the program by tag.

This was pointed out in review but I misunderstood the comment.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 tools/bpf/bpftool/Documentation/bpftool-prog.rst | 2 +-
 tools/bpf/bpftool/main.h                         | 3 +--
 tools/bpf/bpftool/prog.c                         | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/bpf/bpftool/Documentation/bpftool-prog.rst b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
index 04d12f768f06..3968f0bd37db 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-prog.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
@@ -55,7 +55,7 @@ EXAMPLES
 **# bpftool prog show**
 ::
 
-  10: xdp  name some_prog  tag 00:5a:3d:21:23:62:0c:8b
+  10: xdp  name some_prog  tag 005a3d2123620c8b
 	loaded_at Sep 29/20:11  uid 0
 	xlated 528B  jited 370B  memlock 4096B  map_ids 10
 
diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
index 8e809b2bb311..844e4ef6db56 100644
--- a/tools/bpf/bpftool/main.h
+++ b/tools/bpf/bpftool/main.h
@@ -53,8 +53,7 @@
 #define NEXT_ARGP()	({ (*argc)--; (*argv)++; if (*argc < 0) usage(); })
 #define BAD_ARG()	({ err("what is '%s'?\n", *argv); -1; })
 
-#define BPF_TAG_FMT	"%02hhx:%02hhx:%02hhx:%02hhx:"	\
-			"%02hhx:%02hhx:%02hhx:%02hhx"
+#define BPF_TAG_FMT	"%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
 
 #define HELP_SPEC_PROGRAM						\
 	"PROG := { id PROG_ID | pinned FILE | tag PROG_TAG }"
diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index 9e2681c83717..d60f5307b6e2 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -224,7 +224,7 @@ static int show_prog(int fd)
 		printf("name %s  ", info.name);
 
 	printf("tag ");
-	print_hex(info.tag, BPF_TAG_SIZE, ":");
+	print_hex(info.tag, BPF_TAG_SIZE, "");
 	printf("\n");
 
 	if (info.load_time) {
-- 
2.14.1
