From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 7/8] tools: bpftool: show that `opcodes` or `file FILE` should be exclusive
Date: Thu, 19 Oct 2017 15:46:25 -0700
Message-ID: <20171019224626.31608-8-jakub.kicinski@netronome.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:48392 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753268AbdJSWrP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id b79so8112029pfk.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:15 -0700 (PDT)
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

For the `bpftool prog dump { jited | xlated } ...` command, adding
`opcodes` keyword (to request opcodes to be printed) will have no effect
if `file FILE` (to write binary output to FILE) is provided.

The manual page and the help message to be displayed in the terminal
should reflect that, and indicate that these options should be mutually
exclusive.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/Documentation/bpftool-prog.rst | 8 ++++----
 tools/bpf/bpftool/prog.c                         | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/bpf/bpftool/Documentation/bpftool-prog.rst b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
index 3968f0bd37db..69b3770370c8 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-prog.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
@@ -11,8 +11,8 @@ SYNOPSIS
 ========
 
 |	**bpftool** prog show [*PROG*]
-|	**bpftool** prog dump xlated *PROG* [file *FILE*] [opcodes]
-|	**bpftool** prog dump jited  *PROG* [file *FILE*] [opcodes]
+|	**bpftool** prog dump xlated *PROG* [{file *FILE* | opcodes }]
+|	**bpftool** prog dump jited  *PROG* [{file *FILE* | opcodes }]
 |	**bpftool** prog pin *PROG* *FILE*
 |	**bpftool** prog help
 |
@@ -28,14 +28,14 @@ DESCRIPTION
 		  Output will start with program ID followed by program type and
 		  zero or more named attributes (depending on kernel version).
 
-	**bpftool prog dump xlated** *PROG* [**file** *FILE*] [**opcodes**]
+	**bpftool prog dump xlated** *PROG* [{ **file** *FILE* | **opcodes** }]
 		  Dump eBPF instructions of the program from the kernel.
 		  If *FILE* is specified image will be written to a file,
 		  otherwise it will be disassembled and printed to stdout.
 
 		  **opcodes** controls if raw opcodes will be printed.
 
-	**bpftool prog dump jited**  *PROG* [**file** *FILE*] [**opcodes**]
+	**bpftool prog dump jited**  *PROG* [{ **file** *FILE* | **opcodes** }]
 		  Dump jited image (host machine code) of the program.
 		  If *FILE* is specified image will be written to a file,
 		  otherwise it will be disassembled and printed to stdout.
diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index 57edbea2fbe8..7838206a455b 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -469,8 +469,8 @@ static int do_help(int argc, char **argv)
 {
 	fprintf(stderr,
 		"Usage: %s %s show [PROG]\n"
-		"       %s %s dump xlated PROG [file FILE] [opcodes]\n"
-		"       %s %s dump jited  PROG [file FILE] [opcodes]\n"
+		"       %s %s dump xlated PROG [{ file FILE | opcodes }]\n"
+		"       %s %s dump jited  PROG [{ file FILE | opcodes }]\n"
 		"       %s %s pin   PROG FILE\n"
 		"       %s %s help\n"
 		"\n"
-- 
2.14.1
