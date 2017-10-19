From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 8/8] tools: bpftool: add a command to display bpftool version
Date: Thu, 19 Oct 2017 15:46:26 -0700
Message-ID: <20171019224626.31608-9-jakub.kicinski@netronome.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:56039 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751718AbdJSWrR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:17 -0400
Received: by mail-pf0-f194.google.com with SMTP id 17so8106116pfn.12
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:17 -0700 (PDT)
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

This command can be used to print the version of the tool, which is in
fact the version from Linux taken from usr/include/linux/version.h.

Example usage:

    $ bpftool version
    bpftool v4.14.0

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/Documentation/bpftool.rst |  2 ++
 tools/bpf/bpftool/main.c                    | 14 +++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/tools/bpf/bpftool/Documentation/bpftool.rst b/tools/bpf/bpftool/Documentation/bpftool.rst
index f1df1893fb54..45ad8baf1915 100644
--- a/tools/bpf/bpftool/Documentation/bpftool.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool.rst
@@ -14,6 +14,8 @@ SYNOPSIS
 
 	**bpftool** batch file *FILE*
 
+	**bpftool** version
+
 	*OBJECT* := { **map** | **program** }
 
 	*MAP-COMMANDS* :=
diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 8662199ee050..814d19e1b53f 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -37,6 +37,7 @@
 #include <ctype.h>
 #include <errno.h>
 #include <linux/bpf.h>
+#include <linux/version.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -62,13 +63,23 @@ static int do_help(int argc, char **argv)
 	fprintf(stderr,
 		"Usage: %s OBJECT { COMMAND | help }\n"
 		"       %s batch file FILE\n"
+		"       %s version\n"
 		"\n"
 		"       OBJECT := { prog | map }\n",
-		bin_name, bin_name);
+		bin_name, bin_name, bin_name);
 
 	return 0;
 }
 
+static int do_version(int argc, char **argv)
+{
+	printf("%s v%d.%d.%d\n", bin_name,
+	       LINUX_VERSION_CODE >> 16,
+	       LINUX_VERSION_CODE >> 8 & 0xf,
+	       LINUX_VERSION_CODE & 0xf);
+	return 0;
+}
+
 int cmd_select(const struct cmd *cmds, int argc, char **argv,
 	       int (*help)(int argc, char **argv))
 {
@@ -128,6 +139,7 @@ static const struct cmd cmds[] = {
 	{ "batch",	do_batch },
 	{ "prog",	do_prog },
 	{ "map",	do_map },
+	{ "version",	do_version },
 	{ 0 }
 };
 
-- 
2.14.1
