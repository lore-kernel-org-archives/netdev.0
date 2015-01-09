From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 5/6] kbuild: Don't pass -rR to selftest makefiles
Date: Fri,  9 Jan 2015 20:06:14 +1100
Message-ID: <1420794375-31881-5-git-send-email-mpe@ellerman.id.au>
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
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The makefiles under tools/testing/selftests are not real kbuild
makefiles, they are regular stand alone makefiles. As such they *do*
want all the standard implicit rules and variables defined.

So before calling those makefiles, filter -rR out of MAKEFLAGS.

Without this not all the selftests are built correctly when called via
the top-level Makefile.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index c186a928d8be..8bbd0bc7329c 100644
--- a/Makefile
+++ b/Makefile
@@ -1079,12 +1079,12 @@ INSTALL_SELFTESTS_PATH = $(abspath $(objtree)/selftests)
 
 PHONY += kselftest
 kselftest:
-	$(Q)$(MAKE) -C tools/testing/selftests run_tests
+	$(Q)$(MAKE) -C tools/testing/selftests MAKEFLAGS="$(filter-out rR,$(MAKEFLAGS))" run_tests
 
 # Kernel selftest install
 PHONY += kselftest_install
 kselftest_install:
-	$(Q)$(MAKE) -C tools/testing/selftests INSTALL_PATH=$(INSTALL_SELFTESTS_PATH) install
+	$(Q)$(MAKE) -C tools/testing/selftests MAKEFLAGS="$(filter-out rR,$(MAKEFLAGS))" INSTALL_PATH=$(INSTALL_SELFTESTS_PATH) install
 
 # ---------------------------------------------------------------------------
 # Modules
-- 
2.1.0

