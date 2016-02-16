From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V6 2/8] test_bitmap: unit tests for lib/bitmap.c
Date: Tue, 16 Feb 2016 07:32:38 -0500
Message-ID: <1455625964-8943-3-git-send-email-kan.liang@intel.com>
References: <1455625964-8943-1-git-send-email-kan.liang@intel.com>
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31690 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795AbcBPTxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 14:53:01 -0500
In-Reply-To: <1455625964-8943-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

This is mainly testing bitmap construction and conversion to/from u32[]
for now.

Tested:
  qemu i386, x86_64, ppc, ppc64 BE and LE, ARM.

Signed-off-by: David Decotigny <decot@googlers.com>
---
 lib/Kconfig.debug                    | 8 ++++++++
 lib/Makefile                         | 1 +
 tools/testing/selftests/lib/Makefile | 2 +-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ecb9e75..f890ee5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1738,6 +1738,14 @@ config TEST_KSTRTOX
 config TEST_PRINTF
 	tristate "Test printf() family of functions at runtime"
 
+config TEST_BITMAP
+	tristate "Test bitmap_*() family of functions at runtime"
+	default n
+	help
+	  Enable this option to test the bitmap functions at boot.
+
+	  If unsure, say N.
+
 config TEST_RHASHTABLE
 	tristate "Perform selftest on resizable hash table"
 	default n
diff --git a/lib/Makefile b/lib/Makefile
index a7c26a4..dda4039 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
 obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
 obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
 obj-$(CONFIG_TEST_PRINTF) += test_printf.o
+obj-$(CONFIG_TEST_BITMAP) += test_bitmap.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff --git a/tools/testing/selftests/lib/Makefile b/tools/testing/selftests/lib/Makefile
index 47147b9..0836006 100644
--- a/tools/testing/selftests/lib/Makefile
+++ b/tools/testing/selftests/lib/Makefile
@@ -3,6 +3,6 @@
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
 all:
 
-TEST_PROGS := printf.sh
+TEST_PROGS := printf.sh bitmap.sh
 
 include ../lib.mk
-- 
1.8.3.1
