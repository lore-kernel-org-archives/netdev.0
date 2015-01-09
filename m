From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 6/6] selftests: Set CC using CROSS_COMPILE once in lib.mk
Date: Fri,  9 Jan 2015 20:06:15 +1100
Message-ID: <1420794375-31881-6-git-send-email-mpe@ellerman.id.au>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Cc: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	cov@codeaurora.org, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, shuahkh@osg.samsung.com
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:55085 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755883AbbAIJGx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 04:06:53 -0500
In-Reply-To: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 tools/testing/selftests/efivarfs/Makefile | 1 -
 tools/testing/selftests/exec/Makefile     | 1 -
 tools/testing/selftests/kcmp/Makefile     | 1 -
 tools/testing/selftests/lib.mk            | 6 ++++++
 tools/testing/selftests/net/Makefile      | 1 -
 tools/testing/selftests/powerpc/Makefile  | 3 +--
 tools/testing/selftests/size/Makefile     | 2 --
 tools/testing/selftests/vm/Makefile       | 1 -
 8 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/tools/testing/selftests/efivarfs/Makefile b/tools/testing/selftests/efivarfs/Makefile
index 3052d0bda24b..d683486a859b 100644
--- a/tools/testing/selftests/efivarfs/Makefile
+++ b/tools/testing/selftests/efivarfs/Makefile
@@ -1,4 +1,3 @@
-CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
 
 test_objs = open-unlink create-read
diff --git a/tools/testing/selftests/exec/Makefile b/tools/testing/selftests/exec/Makefile
index 886cabe307b1..4edb7d0da29b 100644
--- a/tools/testing/selftests/exec/Makefile
+++ b/tools/testing/selftests/exec/Makefile
@@ -1,4 +1,3 @@
-CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
 BINARIES = execveat
 DEPS = execveat.symlink execveat.denatured script subdir
diff --git a/tools/testing/selftests/kcmp/Makefile b/tools/testing/selftests/kcmp/Makefile
index 0eecd183058c..2ae7450a9a89 100644
--- a/tools/testing/selftests/kcmp/Makefile
+++ b/tools/testing/selftests/kcmp/Makefile
@@ -1,4 +1,3 @@
-CC := $(CROSS_COMPILE)$(CC)
 CFLAGS += -I../../../../usr/include/
 
 all: kcmp_test
diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
index 7bd3dabe2846..abae16396c43 100644
--- a/tools/testing/selftests/lib.mk
+++ b/tools/testing/selftests/lib.mk
@@ -1,3 +1,9 @@
+# When we're called from kbuild $(CC) already contains $(CROSS_COMPILE), so
+# here we need to use "cc", otherwise we'll get $(CROSS_COMPILE) twice. The
+# only downside is it breaks someone overriding $(CC), but that's probably OK,
+# they can probably cope by changing their path.
+CC := $(CROSS_COMPILE)cc
+
 define RUN_TESTS
 	@for TEST in $(TEST_PROGS); do \
 		(./$$TEST && echo "selftests: $$TEST [PASS]") || echo "selftests: $$TEST [FAIL]"; \
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 6ba2ac7bbb0d..fac4782c51d8 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -1,6 +1,5 @@
 # Makefile for net selftests
 
-CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/
diff --git a/tools/testing/selftests/powerpc/Makefile b/tools/testing/selftests/powerpc/Makefile
index d2d19db7eda7..af3882a01e33 100644
--- a/tools/testing/selftests/powerpc/Makefile
+++ b/tools/testing/selftests/powerpc/Makefile
@@ -8,10 +8,9 @@ ifeq ($(ARCH),powerpc)
 
 GIT_VERSION = $(shell git describe --always --long --dirty || echo "unknown")
 
-CC := $(CROSS_COMPILE)$(CC)
 CFLAGS := -Wall -O2 -flto -Wall -Werror -DGIT_VERSION='"$(GIT_VERSION)"' -I$(CURDIR) $(CFLAGS)
 
-export CC CFLAGS
+export CFLAGS
 
 TARGETS = pmu copyloops mm tm primitives
 
diff --git a/tools/testing/selftests/size/Makefile b/tools/testing/selftests/size/Makefile
index e4353d74ea6e..bbd0b5398b61 100644
--- a/tools/testing/selftests/size/Makefile
+++ b/tools/testing/selftests/size/Makefile
@@ -1,5 +1,3 @@
-CC = $(CROSS_COMPILE)gcc
-
 all: get_size
 
 get_size: get_size.c
diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index c0462182ec37..0dd26947fc68 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -1,6 +1,5 @@
 # Makefile for vm selftests
 
-CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
 BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
 BINARIES += transhuge-stress
-- 
2.1.0
