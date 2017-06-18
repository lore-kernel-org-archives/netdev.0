From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH 3/3] selftest/net/Makefile: Specify output with $(OUTPUT)
Date: Sun, 18 Jun 2017 09:56:04 +0900
Message-ID: <20170618005604.17639-4-sj38.park@gmail.com>
References: <20170618005604.17639-1-sj38.park@gmail.com>
Cc: bamvor.zhangjian@linaro.org, shorne@gmail.com, davem@davemloft.net,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>
To: shuah@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618005604.17639-1-sj38.park@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit a8ba798bc8ec ("selftests: enable O and KBUILD_OUTPUT"),
net selftest build fails because it points output file without $(OUTPUT)
yet.  This commit fixes the error.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
Fixes: a8ba798bc8ec ("selftests: enable O and KBUILD_OUTPUT")
---
 tools/testing/selftests/net/Makefile | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 35cbb4cba410..f6c9dbf478f8 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -3,8 +3,6 @@
 CFLAGS =  -Wall -Wl,--no-as-needed -O2 -g
 CFLAGS += -I../../../../usr/include/
 
-reuseport_bpf_numa: LDFLAGS += -lnuma
-
 TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh
 TEST_GEN_FILES =  socket
 TEST_GEN_FILES += psock_fanout psock_tpacket
@@ -13,3 +11,4 @@ TEST_GEN_FILES += reuseport_dualstack
 
 include ../lib.mk
 
+$(OUTPUT)/reuseport_bpf_numa: LDFLAGS += -lnuma
-- 
2.13.0
