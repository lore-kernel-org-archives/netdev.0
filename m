From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] testsuite: skip link show test on big endian systems
Date: Wed,  8 Feb 2017 00:04:21 +0100
Message-ID: <20170207230422.31936-2-phil@nwl.cc>
References: <20170207230422.31936-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48821 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753798AbdBGXF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 18:05:29 -0500
In-Reply-To: <20170207230422.31936-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netlink protocol is in host byte order, so the provided binary netlink
message buffer being in little endian format will cause the test to fail
on big endian systems.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 .gitignore                                    | 1 +
 testsuite/Makefile                            | 1 +
 testsuite/tests/ip/link/show_dev_wo_vf_rate.t | 5 +++++
 testsuite/tools/Makefile                      | 2 ++
 testsuite/tools/is_big_endian.c               | 7 +++++++
 5 files changed, 16 insertions(+)
 create mode 100644 testsuite/tools/Makefile
 create mode 100644 testsuite/tools/is_big_endian.c

diff --git a/.gitignore b/.gitignore
index 74a5496ddf7aa..a1f295dac3dd2 100644
--- a/.gitignore
+++ b/.gitignore
@@ -36,6 +36,7 @@ series
 # tests
 testsuite/results
 testsuite/iproute2/iproute2-this
+testsuite/tools/is_big_endian
 
 # doc files generated at runtime
 doc/*.aux
diff --git a/testsuite/Makefile b/testsuite/Makefile
index 2027650051d48..17568881b8b66 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -24,6 +24,7 @@ configure:
 
 compile: configure
 	echo "Entering iproute2" && cd iproute2 && $(MAKE) && cd ..;
+	echo "Entering tools" && cd tools && $(MAKE) && cd ..;
 
 listtests:
 	@for t in $(TESTS); do \
diff --git a/testsuite/tests/ip/link/show_dev_wo_vf_rate.t b/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
index a600ba65c5bec..ad90af5400271 100755
--- a/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
+++ b/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
@@ -2,5 +2,10 @@
 
 source lib/generic.sh
 
+if ./tools/is_big_endian; then
+	ts_log "won't work on big endian system"
+	ts_skip
+fi
+
 NL_FILE="tests/ip/link/dev_wo_vf_rate.nl"
 ts_ip "$0" "Show VF devices w/o VF rate info" -d monitor file $NL_FILE
diff --git a/testsuite/tools/Makefile b/testsuite/tools/Makefile
new file mode 100644
index 0000000000000..ecbea16c2c1cc
--- /dev/null
+++ b/testsuite/tools/Makefile
@@ -0,0 +1,2 @@
+is_big_endian: is_big_endian.c
+	$(CC) -o $@ $<
diff --git a/testsuite/tools/is_big_endian.c b/testsuite/tools/is_big_endian.c
new file mode 100644
index 0000000000000..303e91b4603e8
--- /dev/null
+++ b/testsuite/tools/is_big_endian.c
@@ -0,0 +1,7 @@
+//#include <stdio.h>
+#include <arpa/inet.h>
+
+int main(void)
+{
+	return 1 != ntohs(1);
+}
-- 
2.11.0
