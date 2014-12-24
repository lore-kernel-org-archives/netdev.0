From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v3 20/20] kbuild: add a new kselftest_install make target to install selftests
Date: Wed, 24 Dec 2014 09:27:56 -0700
Message-ID: <05d750bb46f4f20c668b13c312c520c1e56f7ba1.1419387513.git.shuahkh@osg.samsung.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	mpe@ellerman.id.au, cov@codeaurora.org, dh.herrmann@gmail.com,
	hughd@google.com, bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1419387513.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1419387513.git.shuahkh@osg.samsung.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to install to install kernel selftests.
This new target will build and install selftests. kselftest
target now depends on kselftest_install and runs the generated
kselftest script to reduce duplicate work and for common look
and feel when running tests.

make kselftest_target:
-- exports kselftest INSTALL_KSFT_PATH
   default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
-- exports INSTALL_KSFT_PATH
-- runs selftests make install target:

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Makefile | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/Makefile b/Makefile
index b1c3254..99fac47 100644
--- a/Makefile
+++ b/Makefile
@@ -1072,12 +1072,21 @@ headers_check: headers_install
 	$(Q)$(MAKE) $(hdr-inst)=arch/$(hdr-arch)/include/uapi/asm $(hdr-dst) HDRCHECK=1
 
 # ---------------------------------------------------------------------------
-# Kernel selftest
+# Kernel selftest targets
+
+# Default base path for kselftest install
+INSTALL_KSFT_PATH = $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
+export INSTALL_KSFT_PATH
 
 PHONY += kselftest
 kselftest:
 	$(Q)$(MAKE) -C tools/testing/selftests run_tests
 
+# Kernel selftest install
+PHONY += kselftest_install
+kselftest_install:
+	$(Q)$(MAKE) -C tools/testing/selftests install
+
 # ---------------------------------------------------------------------------
 # Modules
 
@@ -1286,6 +1295,9 @@ help:
 	@echo  '                    Build, install, and boot kernel before'
 	@echo  '                    running kselftest on it'
 	@echo  ''
+	@echo  '  kselftest_install - Install Kselftests to INSTALL_KSFT_PATH'
+	@echo  '                      default: $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)'
+	@echo  ''
 	@echo  'Kernel packaging:'
 	@$(MAKE) $(build)=$(package-dir) help
 	@echo  ''
-- 
2.1.0
