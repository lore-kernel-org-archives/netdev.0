From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1] bpf: Rebuild bpf.o for any dependency update
Date: Sat, 11 Feb 2017 23:20:23 +0100
Message-ID: <20170211222023.19920-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is needed to force a rebuild of bpf.o when one of its dependencies
(e.g. uapi/linux/bpf.h) is updated.

Add a phony target.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Wang Nan <wangnan0@huawei.com>
---
 tools/testing/selftests/bpf/Makefile | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index a35f564f66a1..c7816fe60feb 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,13 +1,24 @@
-CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I../../../lib
+LIBDIR := ../../../lib
+BPFOBJ := $(LIBDIR)/bpf/bpf.o
+
+CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I$(LIBDIR)
 
 test_objs = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
 TEST_PROGS := $(test_objs) test_kmod.sh
 TEST_FILES := $(test_objs)
 
+.PHONY: all clean force
+
 all: $(test_objs)
 
-$(test_objs): ../../../lib/bpf/bpf.o
+# force a rebuild of BPFOBJ when its dependencies are updated
+force:
+
+$(BPFOBJ): force
+	$(MAKE) -C $(dir $(BPFOBJ))
+
+$(test_objs): $(BPFOBJ)
 
 include ../lib.mk
 
-- 
2.11.0
