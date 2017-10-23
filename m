From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/12] tools: bpftool: update documentation for --json and --pretty usage
Date: Mon, 23 Oct 2017 09:24:16 -0700
Message-ID: <20171023162416.32753-13-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:47458 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdJWQZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:25:06 -0400
Received: by mail-pg0-f67.google.com with SMTP id r25so12163513pgn.4
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:25:06 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Update the documentation to provide help about JSON output generation,
and add an example in bpftool-prog manual page.

Also reintroduce an example that was left aside when the tool was moved
from GitHub to the kernel sources, in order to show how to mount the
bpffs file system (to pin programs) inside the bpftool-prog manual page.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/Documentation/bpftool-map.rst  | 11 ++++-
 tools/bpf/bpftool/Documentation/bpftool-prog.rst | 61 +++++++++++++++++++++++-
 tools/bpf/bpftool/Documentation/bpftool.rst      | 12 ++++-
 tools/bpf/bpftool/main.c                         |  6 ++-
 tools/bpf/bpftool/main.h                         |  2 +
 tools/bpf/bpftool/map.c                          |  1 +
 tools/bpf/bpftool/prog.c                         |  1 +
 7 files changed, 88 insertions(+), 6 deletions(-)

diff --git a/tools/bpf/bpftool/Documentation/bpftool-map.rst b/tools/bpf/bpftool/Documentation/bpftool-map.rst
index 3954b3ea4f26..abb9ee940b15 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-map.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-map.rst
@@ -10,7 +10,9 @@ tool for inspection and simple manipulation of eBPF maps
 SYNOPSIS
 ========
 
-	**bpftool** **map** *COMMAND*
+	**bpftool** [*OPTIONS*] **map** *COMMAND*
+
+	*OPTIONS* := { { **-j** | **--json** } [{ **-p** | **--pretty** }] }
 
 	*COMMANDS* :=
 	{ **show** | **dump** | **update** | **lookup** | **getnext** | **delete**
@@ -77,6 +79,13 @@ OPTIONS
 	-v, --version
 		  Print version number (similar to **bpftool version**).
 
+	-j, --json
+		  Generate JSON output. For commands that cannot produce JSON, this
+		  option has no effect.
+
+	-p, --pretty
+		  Generate human-readable JSON output. Implies **-j**.
+
 EXAMPLES
 ========
 **# bpftool map show**
diff --git a/tools/bpf/bpftool/Documentation/bpftool-prog.rst b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
index 685a19e71fec..0f25d3c39e05 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-prog.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
@@ -10,6 +10,16 @@ tool for inspection and simple manipulation of eBPF progs
 SYNOPSIS
 ========
 
+	**bpftool** [*OPTIONS*] **prog** *COMMAND*
+
+	*OPTIONS* := { { **-j** | **--json** } [{ **-p** | **--pretty** }] }
+
+	*COMMANDS* :=
+	{ **show** | **dump xlated** | **dump jited** | **pin** | **help** }
+
+MAP COMMANDS
+=============
+
 |	**bpftool** **prog show** [*PROG*]
 |	**bpftool** **prog dump xlated** *PROG* [{**file** *FILE* | **opcodes**}]
 |	**bpftool** **prog dump jited**  *PROG* [{**file** *FILE* | **opcodes**}]
@@ -58,6 +68,13 @@ OPTIONS
 	-v, --version
 		  Print version number (similar to **bpftool version**).
 
+	-j, --json
+		  Generate JSON output. For commands that cannot produce JSON, this
+		  option has no effect.
+
+	-p, --pretty
+		  Generate human-readable JSON output. Implies **-j**.
+
 EXAMPLES
 ========
 **# bpftool prog show**
@@ -67,13 +84,33 @@ EXAMPLES
 	loaded_at Sep 29/20:11  uid 0
 	xlated 528B  jited 370B  memlock 4096B  map_ids 10
 
+**# bpftool --json --pretty prog show**
+
+::
+
+    {
+        "programs": [{
+                "id": 10,
+                "type": "xdp",
+                "tag": "005a3d2123620c8b",
+                "loaded_at": "Sep 29/20:11",
+                "uid": 0,
+                "bytes_xlated": 528,
+                "jited": true,
+                "bytes_jited": 370,
+                "bytes_memlock": 4096,
+                "map_ids": [10
+                ]
+            }
+        ]
+    }
+
 |
 | **# bpftool prog dump xlated id 10 file /tmp/t**
 | **# ls -l /tmp/t**
 |   -rw------- 1 root root 560 Jul 22 01:42 /tmp/t
 
-|
-| **# bpftool prog dum jited pinned /sys/fs/bpf/prog**
+**# bpftool prog dum jited tag 005a3d2123620c8b**
 
 ::
 
@@ -83,6 +120,26 @@ EXAMPLES
     sub    $0x28,%rbp
     mov    %rbx,0x0(%rbp)
 
+|
+| **# mount -t bpf none /sys/fs/bpf/**
+| **# bpftool prog pin id 10 /sys/fs/bpf/prog**
+| **# ls -l /sys/fs/bpf/**
+|   -rw------- 1 root root 0 Jul 22 01:43 prog
+
+**# bpftool prog dum jited pinned /sys/fs/bpf/prog opcodes**
+
+::
+
+    push   %rbp
+    55
+    mov    %rsp,%rbp
+    48 89 e5
+    sub    $0x228,%rsp
+    48 81 ec 28 02 00 00
+    sub    $0x28,%rbp
+    48 83 ed 28
+    mov    %rbx,0x0(%rbp)
+    48 89 5d 00
 
 
 SEE ALSO
diff --git a/tools/bpf/bpftool/Documentation/bpftool.rst b/tools/bpf/bpftool/Documentation/bpftool.rst
index 44e07799d54d..926c03d5a8da 100644
--- a/tools/bpf/bpftool/Documentation/bpftool.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool.rst
@@ -10,7 +10,7 @@ tool for inspection and simple manipulation of eBPF programs and maps
 SYNOPSIS
 ========
 
-	**bpftool** *OBJECT* { *COMMAND* | **help** }
+	**bpftool** [*OPTIONS*] *OBJECT* { *COMMAND* | **help** }
 
 	**bpftool** **batch file** *FILE*
 
@@ -18,6 +18,9 @@ SYNOPSIS
 
 	*OBJECT* := { **map** | **program** }
 
+	*OPTIONS* := { { **-V** | **--version** } | { **-h** | **--help** }
+	| { **-j** | **--json** } [{ **-p** | **--pretty** }] }
+
 	*MAP-COMMANDS* :=
 	{ **show** | **dump** | **update** | **lookup** | **getnext** | **delete**
 	| **pin** | **help** }
@@ -41,6 +44,13 @@ OPTIONS
 	-v, --version
 		  Print version number (similar to **bpftool version**).
 
+	-j, --json
+		  Generate JSON output. For commands that cannot produce JSON, this
+		  option has no effect.
+
+	-p, --pretty
+		  Generate human-readable JSON output. Implies **-j**.
+
 SEE ALSO
 ========
 	**bpftool-map**\ (8), **bpftool-prog**\ (8)
diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 55ba0a04c102..78d9afb74ef4 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -70,11 +70,13 @@ static int do_help(int argc, char **argv)
 	}
 
 	fprintf(stderr,
-		"Usage: %s OBJECT { COMMAND | help }\n"
+		"Usage: %s [OPTIONS] OBJECT { COMMAND | help }\n"
 		"       %s batch file FILE\n"
 		"       %s version\n"
 		"\n"
-		"       OBJECT := { prog | map }\n",
+		"       OBJECT := { prog | map }\n"
+		"       " HELP_SPEC_OPTIONS "\n"
+		"",
 		bin_name, bin_name, bin_name);
 
 	return 0;
diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
index 04c88b55d8c7..2f94bed03a8d 100644
--- a/tools/bpf/bpftool/main.h
+++ b/tools/bpf/bpftool/main.h
@@ -55,6 +55,8 @@
 
 #define HELP_SPEC_PROGRAM						\
 	"PROG := { id PROG_ID | pinned FILE | tag PROG_TAG }"
+#define HELP_SPEC_OPTIONS						\
+	"OPTIONS := { {-j|--json} [{-p|--pretty}] }"
 
 enum bpf_obj_type {
 	BPF_OBJ_UNKNOWN,
diff --git a/tools/bpf/bpftool/map.c b/tools/bpf/bpftool/map.c
index a611f31f574f..e978ab23a77f 100644
--- a/tools/bpf/bpftool/map.c
+++ b/tools/bpf/bpftool/map.c
@@ -850,6 +850,7 @@ static int do_help(int argc, char **argv)
 		"       " HELP_SPEC_PROGRAM "\n"
 		"       VALUE := { BYTES | MAP | PROG }\n"
 		"       UPDATE_FLAGS := { any | exist | noexist }\n"
+		"       " HELP_SPEC_OPTIONS "\n"
 		"",
 		bin_name, argv[-2], bin_name, argv[-2], bin_name, argv[-2],
 		bin_name, argv[-2], bin_name, argv[-2], bin_name, argv[-2],
diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index e07f35ff80d1..250f80fd46aa 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -625,6 +625,7 @@ static int do_help(int argc, char **argv)
 		"       %s %s help\n"
 		"\n"
 		"       " HELP_SPEC_PROGRAM "\n"
+		"       " HELP_SPEC_OPTIONS "\n"
 		"",
 		bin_name, argv[-2], bin_name, argv[-2], bin_name, argv[-2],
 		bin_name, argv[-2], bin_name, argv[-2]);
-- 
2.14.1
