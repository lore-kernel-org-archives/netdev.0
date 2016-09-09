From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 5/9] selftests: Update prctl Makefile to work under selftests
Date: Fri,  9 Sep 2016 16:22:46 -0600
Message-ID: <77650824f1e884b0999dc3ed258cdfaae159aa6b.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update prctl Makefile to work under selftests. prctl will not be run as
part of selftests suite and will not included in install targets. They
can be built separately for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/prctl/Makefile | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/tools/testing/selftests/prctl/Makefile b/tools/testing/selftests/prctl/Makefile
index 44de308..35aa1c8 100644
--- a/tools/testing/selftests/prctl/Makefile
+++ b/tools/testing/selftests/prctl/Makefile
@@ -1,10 +1,15 @@
 ifndef CROSS_COMPILE
-# List of programs to build
-hostprogs-$(CONFIG_X86) := disable-tsc-ctxt-sw-stress-test disable-tsc-on-off-stress-test disable-tsc-test
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
+uname_M := $(shell uname -m 2>/dev/null || echo not)
+ARCH ?= $(shell echo $(uname_M) | sed -e s/i.86/x86/ -e s/x86_64/x86/)
 
-HOSTCFLAGS_disable-tsc-ctxt-sw-stress-test.o += -I$(objtree)/usr/include
-HOSTCFLAGS_disable-tsc-on-off-stress-test.o += -I$(objtree)/usr/include
-HOSTCFLAGS_disable-tsc-test.o += -I$(objtree)/usr/include
+ifeq ($(ARCH),x86)
+TEST_PROGS := disable-tsc-ctxt-sw-stress-test disable-tsc-on-off-stress-test \
+		disable-tsc-test
+all: $(TEST_PROGS)
+
+include ../lib.mk
+
+clean:
+	rm -fr $(TEST_PROGS)
+endif
 endif
-- 
2.7.4
