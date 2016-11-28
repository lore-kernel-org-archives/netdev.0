From: Colin King <colin.king@canonical.com>
Subject: [PATCH net-next] bpf: selftests: include <sys/resource.h> to fix build error
Date: Mon, 28 Nov 2016 11:45:41 +0000
Message-ID: <20161128114541.10829-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>, Shuah Khan <shuah@kernel.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37237 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753751AbcK1LqC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 06:46:02 -0500
Content-Type: text/plain; charset="utf-8"
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Fix incomplete type build error on struct rlimit by including
<sys/resource.h>, fixes:

test_lru_map.c:552:9: error: variable ‘r’ has initializer
 but incomplete type
  struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
         ^
test_lru_map.c:552:21: error: ‘RLIM_INFINITY’ undeclared
 (first use in this function)
  struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 tools/testing/selftests/bpf/test_lru_map.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 627757e..fde54a2 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -13,6 +13,7 @@
 #include <assert.h>
 #include <sched.h>
 #include <sys/wait.h>
+#include <sys/resource.h>
 #include <stdlib.h>
 #include <time.h>
 #include "bpf_sys.h"
-- 
2.10.2
