From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH 2/3] selftest/intel_pstate/aperf: Use LDLIBS instead of LDFLAGS
Date: Sun, 18 Jun 2017 09:56:03 +0900
Message-ID: <20170618005604.17639-3-sj38.park@gmail.com>
References: <20170618005604.17639-1-sj38.park@gmail.com>
Cc: bamvor.zhangjian@linaro.org, shorne@gmail.com, davem@davemloft.net,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>
To: shuah@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618005604.17639-1-sj38.park@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Build of aperf fails as below:
```
gcc  -Wall -D_GNU_SOURCE   -lm  aperf.c  -o /tools/testing/selftests/intel_pstate/aperf
/tmp/ccKf3GF6.o: In function `main':
aperf.c:(.text+0x278): undefined reference to `sqrt'
collect2: error: ld returned 1 exit status
```

The faulure occurs because -lm was defined as LDFLAGS and implicit rule
of make places LDFLAGS before source file.  This commit fixes the
problem by using LDLIBS instead of LDFLAGS.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 tools/testing/selftests/intel_pstate/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/intel_pstate/Makefile b/tools/testing/selftests/intel_pstate/Makefile
index 19678e90efb2..849a90ffe8dd 100644
--- a/tools/testing/selftests/intel_pstate/Makefile
+++ b/tools/testing/selftests/intel_pstate/Makefile
@@ -1,5 +1,5 @@
 CFLAGS := $(CFLAGS) -Wall -D_GNU_SOURCE
-LDFLAGS := $(LDFLAGS) -lm
+LDLIBS := $(LDLIBS) -lm
 
 TEST_GEN_FILES := msr aperf
 
-- 
2.13.0
