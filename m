From: Joe Stringer <joe@ovn.org>
Subject: [PATCH perf/core] samples/bpf: Drop unnecessary build targets.
Date: Fri,  9 Dec 2016 09:51:09 -0800
Message-ID: <20161209175109.6779-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        acme@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit f72179ef11db ("samples/bpf: Switch over to libbpf") added these
two makefile changes that were unnecessary for switching samples to use
libbpf. The extra make is already handled by the build dependency, and
libbpf target doesn't build because it lacks main(). Remove these.

Reported-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: Joe Stringer <joe@ovn.org>
---
 samples/bpf/Makefile   | 1 -
 tools/lib/bpf/Makefile | 2 --
 2 files changed, 3 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 9ffa6a2c061d..60ffc8115b67 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -127,7 +127,6 @@ CLANG ?= clang
 
 # Trick to allow make to be run from this directory
 all:
-	$(MAKE) -C ../../ tools/lib/bpf/
 	$(MAKE) -C ../../ $$PWD/
 
 clean:
diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
index 616bd55f3be8..62d89d50fcbd 100644
--- a/tools/lib/bpf/Makefile
+++ b/tools/lib/bpf/Makefile
@@ -149,8 +149,6 @@ CMD_TARGETS = $(LIB_FILE)
 
 TARGETS = $(CMD_TARGETS)
 
-libbpf: all
-
 all: fixdep $(VERSION_FILES) all_cmd
 
 all_cmd: $(CMD_TARGETS)
-- 
2.10.2
