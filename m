From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 16/20] selftests/ptrace: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:12 -0700
Message-ID: <c29ba0f8dcdd2bf345a7e92496d17413c7a4acb4.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/ptrace/Makefile | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/ptrace/Makefile b/tools/testing/selftests/ptrace/Makefile
index 47ae2d3..7826045 100644
--- a/tools/testing/selftests/ptrace/Makefile
+++ b/tools/testing/selftests/ptrace/Makefile
@@ -1,7 +1,14 @@
 CFLAGS += -iquote../../../../include/uapi -Wall
-peeksiginfo: peeksiginfo.c
 
-all: peeksiginfo
+all:
+	gcc peeksiginfo.c -o peeksiginfo
+
+install: all
+	install ./peeksiginfo $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start ptrace test ....\"" >> $(KSELFTEST)
+	echo "./peeksiginfo || echo \"peeksiginfo selftests: [FAIL]\"" >> $(KSELFTEST)
+	echo "echo \"End ptrace test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
 
 clean:
 	rm -f peeksiginfo
-- 
1.9.1
