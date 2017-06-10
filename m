From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/8] bpf, tests: set rlimit also for test_align, so it doesn't fail
Date: Sun, 11 Jun 2017 00:50:45 +0200
Message-ID: <1f92ac2c63bc5ab688c036b17e45051df3be65b6.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57836 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbdFJWvA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:51:00 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running all the tests, through 'make run_tests', I had
test_align failing due to insufficient rlimit. Set it the same
way as all other test cases from BPF selftests do, so that
test case properly loads everything.

  [...]
  Summary: 7 PASSED, 1 FAILED
  selftests: test_progs [PASS]
  /home/foo/net-next/tools/testing/selftests/bpf
  Test   0: mov ... Failed to load program.
  FAIL
  Test   1: shift ... Failed to load program.
  FAIL
  Test   2: addsub ... Failed to load program.
  FAIL
  Test   3: mul ... Failed to load program.
  FAIL
  Test   4: unknown shift ... Failed to load program.
  FAIL
  Test   5: unknown mul ... Failed to load program.
  FAIL
  Test   6: packet const offset ... Failed to load program.
  FAIL
  Test   7: packet variable offset ... Failed to load program.
  FAIL
  Results: 0 pass 8 fail
  selftests: test_align [PASS]
  [...]

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/test_align.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index 9644d4e..1426594 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -9,6 +9,8 @@
 #include <stddef.h>
 #include <stdbool.h>
 
+#include <sys/resource.h>
+
 #include <linux/unistd.h>
 #include <linux/filter.h>
 #include <linux/bpf_perf_event.h>
@@ -432,6 +434,9 @@ static int do_test(unsigned int from, unsigned int to)
 int main(int argc, char **argv)
 {
 	unsigned int from = 0, to = ARRAY_SIZE(tests);
+	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
+
+	setrlimit(RLIMIT_MEMLOCK, &rinf);
 
 	if (argc == 3) {
 		unsigned int l = atoi(argv[argc - 2]);
-- 
1.9.3
