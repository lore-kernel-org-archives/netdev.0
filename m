From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH 1/3] selftest/memfd/Makefile: Fix build error
Date: Sun, 18 Jun 2017 09:56:02 +0900
Message-ID: <20170618005604.17639-2-sj38.park@gmail.com>
References: <20170618005604.17639-1-sj38.park@gmail.com>
Cc: bamvor.zhangjian@linaro.org, shorne@gmail.com, davem@davemloft.net,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>
To: shuah@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618005604.17639-1-sj38.park@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Selftest for memfd shows build error as below:
```
gcc -D_FILE_OFFSET_BITS=64 -I../../../../include/uapi/ -I../../../../include/ -I../../../../usr/include/    fuse_mnt.c  -o /home/sjpark/linux/tools/testing/selftests/memfd/fuse_mnt
/tmp/cc6NHdwJ.o: In function `main':
fuse_mnt.c:(.text+0x249): undefined reference to `fuse_main_real'
collect2: error: ld returned 1 exit status
```

The build fails because output file is specified without $(OUTPUT) and
LDFLAGS is used though Makefile implicit rule is used.  This commit
fixes the error by specifying output file path with $(OUTPUT) and using
LDLIBS instead of LDFLAGS.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 tools/testing/selftests/memfd/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
index 79891d033de1..ad8a0897e47f 100644
--- a/tools/testing/selftests/memfd/Makefile
+++ b/tools/testing/selftests/memfd/Makefile
@@ -7,7 +7,7 @@ TEST_PROGS := run_fuse_test.sh
 TEST_GEN_FILES := memfd_test fuse_mnt fuse_test
 
 fuse_mnt.o: CFLAGS += $(shell pkg-config fuse --cflags)
-fuse_mnt: LDFLAGS += $(shell pkg-config fuse --libs)
 
 include ../lib.mk
 
+$(OUTPUT)/fuse_mnt: LDLIBS += $(shell pkg-config fuse --libs)
-- 
2.13.0
