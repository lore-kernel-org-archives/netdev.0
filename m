From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 07/53] tools: Move Makefile.arch from perf/config to tools/scripts
Date: Mon, 11 Jan 2016 13:47:58 +0000
Message-ID: <1452520124-2073-8-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	"Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After this patch other directories can use this architecture detector
without directly including it from perf's directory. Libbpf would
utilize it to get proper $(ARCH) so it can receive correct uapi include
directory.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@kernel.org>
[Add missing srctree definition in tests/make]
Acked-by: Jiri Olsa <jolsa@kernel.org>
Tested-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
Cc: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 tools/perf/config/Makefile                   |  2 +-
 tools/perf/tests/make                        | 16 +++++++++++++++-
 tools/{perf/config => scripts}/Makefile.arch |  0
 3 files changed, 16 insertions(+), 2 deletions(-)
 rename tools/{perf/config => scripts}/Makefile.arch (100%)

diff --git a/tools/perf/config/Makefile b/tools/perf/config/Makefile
index 0793c76..7545ba60 100644
--- a/tools/perf/config/Makefile
+++ b/tools/perf/config/Makefile
@@ -17,7 +17,7 @@ detected_var = $(shell echo "$(1)=$($(1))" >> $(OUTPUT).config-detected)
 
 CFLAGS := $(EXTRA_CFLAGS) $(EXTRA_WARNINGS)
 
-include $(src-perf)/config/Makefile.arch
+include $(srctree)/tools/scripts/Makefile.arch
 
 $(call detected_var,ARCH)
 
diff --git a/tools/perf/tests/make b/tools/perf/tests/make
index 0f5afcb..1e59ce8 100644
--- a/tools/perf/tests/make
+++ b/tools/perf/tests/make
@@ -1,3 +1,5 @@
+include ../scripts/Makefile.include
+
 ifndef MK
 ifeq ($(MAKECMDGOALS),)
 # no target specified, trigger the whole suite
@@ -31,7 +33,19 @@ ifeq ($(SET_PARALLEL),1)
   PARALLEL_OPT="-j$(cores)"
 endif
 
-include config/Makefile.arch
+# As per kernel Makefile, avoid funny character set dependencies
+unexport LC_ALL
+LC_COLLATE=C
+LC_NUMERIC=C
+export LC_COLLATE LC_NUMERIC
+
+ifeq ($(srctree),)
+srctree := $(patsubst %/,%,$(dir $(shell pwd)))
+srctree := $(patsubst %/,%,$(dir $(srctree)))
+#$(info Determined 'srctree' to be $(srctree))
+endif
+
+include $(srctree)/tools/scripts/Makefile.arch
 
 # FIXME looks like x86 is the only arch running tests ;-)
 # we need some IS_(32/64) flag to make this generic
diff --git a/tools/perf/config/Makefile.arch b/tools/scripts/Makefile.arch
similarity index 100%
rename from tools/perf/config/Makefile.arch
rename to tools/scripts/Makefile.arch
-- 
1.8.3.4
