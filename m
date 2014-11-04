From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: [PATCH 08/20] selftests/firmware: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:04 -0700
Message-ID: <a2ce2a487fda9cb4ffe45bf96325b2f9ebd4c215.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mmarek-AlSwsSmVLrQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
In-Reply-To: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
References: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test.

Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
---
 tools/testing/selftests/firmware/Makefile | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/tools/testing/selftests/firmware/Makefile b/tools/testing/selftests/firmware/Makefile
index e23cce0..d5008ec 100644
--- a/tools/testing/selftests/firmware/Makefile
+++ b/tools/testing/selftests/firmware/Makefile
@@ -19,6 +19,26 @@ fw_userhelper:
                 exit 1; \
         fi
 
+install: all
+	install ./fw_filesystem.sh ./fw_userhelper.sh $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start firmware filesystem test ....\"" >> $(KSELFTEST)
+	echo "if /bin/sh ./fw_filesystem.sh ; then \\" >> $(KSELFTEST)
+	echo "\techo \"fw_filesystem: ok \"; \\" >> $(KSELFTEST)
+	echo "else \\" >> $(KSELFTEST)
+	echo "\techo \"fw_filesystem: [FAIL] \"; \\" >> $(KSELFTEST)
+	echo "fi" >> $(KSELFTEST)
+	echo "echo \"End firmware filesystem test ....\"" >> $(KSELFTEST)
+	echo "echo \"--------------------\"" >> $(KSELFTEST)
+
+	echo "echo \"Start firmware userhelper test ....\"" >> $(KSELFTEST)
+	echo "if /bin/sh ./fw_userhelper.sh ; then \\" >> $(KSELFTEST)
+	echo "\techo \"fw_userhelper: ok\"; \\" >> $(KSELFTEST)
+	echo "else \\" >> $(KSELFTEST)
+	echo "\techo \"fw_userhelper: [FAIL] \"; \\" >> $(KSELFTEST)
+	echo "fi" >> $(KSELFTEST)
+	echo "echo \"End firmware userhelper test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests: all fw_filesystem fw_userhelper
 
 # Nothing to clean up.
-- 
1.9.1
