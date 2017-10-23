From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/12] tools: bpftool: add option parsing to bpftool, --help and --version
Date: Mon, 23 Oct 2017 09:24:06 -0700
Message-ID: <20171023162416.32753-3-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:57083 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdJWQY4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:24:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so17461152pfj.13
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:24:56 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Add an option parsing facility to bpftool, in prevision of future
options for demanding JSON output. Currently, two options are added:
--help and --version, that act the same as the respective commands
`help` and `version`.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/Documentation/bpftool-map.rst  |  8 +++++++
 tools/bpf/bpftool/Documentation/bpftool-prog.rst |  8 +++++++
 tools/bpf/bpftool/Documentation/bpftool.rst      |  8 +++++++
 tools/bpf/bpftool/main.c                         | 27 +++++++++++++++++++++++-
 4 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/tools/bpf/bpftool/Documentation/bpftool-map.rst b/tools/bpf/bpftool/Documentation/bpftool-map.rst
index ff63e89e4b6c..5210c4fab356 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-map.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-map.rst
@@ -68,6 +68,14 @@ DESCRIPTION
 	**bpftool map help**
 		  Print short help message.
 
+OPTIONS
+=======
+	-h, --help
+		  Print short generic help message (similar to **bpftool help**).
+
+	-v, --version
+		  Print version number (similar to **bpftool version**).
+
 EXAMPLES
 ========
 **# bpftool map show**
diff --git a/tools/bpf/bpftool/Documentation/bpftool-prog.rst b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
index 69b3770370c8..6620a81d9dc9 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-prog.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
@@ -50,6 +50,14 @@ DESCRIPTION
 	**bpftool prog help**
 		  Print short help message.
 
+OPTIONS
+=======
+	-h, --help
+		  Print short generic help message (similar to **bpftool help**).
+
+	-v, --version
+		  Print version number (similar to **bpftool version**).
+
 EXAMPLES
 ========
 **# bpftool prog show**
diff --git a/tools/bpf/bpftool/Documentation/bpftool.rst b/tools/bpf/bpftool/Documentation/bpftool.rst
index 45ad8baf1915..9c04cd6677bd 100644
--- a/tools/bpf/bpftool/Documentation/bpftool.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool.rst
@@ -31,6 +31,14 @@ DESCRIPTION
 	Note that format of the output of all tools is not guaranteed to be
 	stable and should not be depended upon.
 
+OPTIONS
+=======
+	-h, --help
+		  Print short help message (similar to **bpftool help**).
+
+	-v, --version
+		  Print version number (similar to **bpftool version**).
+
 SEE ALSO
 ========
 	**bpftool-map**\ (8), **bpftool-prog**\ (8)
diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 814d19e1b53f..613e3c75f78a 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -36,6 +36,7 @@
 #include <bfd.h>
 #include <ctype.h>
 #include <errno.h>
+#include <getopt.h>
 #include <linux/bpf.h>
 #include <linux/version.h>
 #include <stdio.h>
@@ -215,8 +216,32 @@ static int do_batch(int argc, char **argv)
 
 int main(int argc, char **argv)
 {
+	static const struct option options[] = {
+		{ "help",	no_argument,	NULL,	'h' },
+		{ "version",	no_argument,	NULL,	'V' },
+		{ 0 }
+	};
+	int opt;
+
+	last_do_help = do_help;
 	bin_name = argv[0];
-	NEXT_ARG();
+
+	while ((opt = getopt_long(argc, argv, "Vh",
+				  options, NULL)) >= 0) {
+		switch (opt) {
+		case 'V':
+			return do_version(argc, argv);
+		case 'h':
+			return do_help(argc, argv);
+		default:
+			usage();
+		}
+	}
+
+	argc -= optind;
+	argv += optind;
+	if (argc < 0)
+		usage();
 
 	bfd_init();
 
-- 
2.14.1
