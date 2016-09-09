From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 7/9] selftests: Update ptp Makefile to work under selftests
Date: Fri,  9 Sep 2016 16:22:48 -0600
Message-ID: <cade45ccc160f91658980cda42ef5b5322182d68.1473458697.git.shuahkh@osg.samsung.com>
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

Update ptp Makefile to work under selftests. ptp will not be run as part
of selftests suite and will not included in install targets. They can be
built separately for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/ptp/Makefile | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/testing/selftests/ptp/Makefile b/tools/testing/selftests/ptp/Makefile
index 293d6c0..f4a7238 100644
--- a/tools/testing/selftests/ptp/Makefile
+++ b/tools/testing/selftests/ptp/Makefile
@@ -1,8 +1,8 @@
-# List of programs to build
-hostprogs-y := testptp
+TEST_PROGS := testptp
+LDLIBS += -lrt
+all: $(TEST_PROGS)
 
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
+include ../lib.mk
 
-HOSTCFLAGS_testptp.o += -I$(objtree)/usr/include
-HOSTLOADLIBES_testptp := -lrt
+clean:
+	rm -fr testptp
-- 
2.7.4
