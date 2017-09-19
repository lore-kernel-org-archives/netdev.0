From: josef@toxicpanda.com
Subject: [PATCH 2/3][v2] selftests: actually run the various net selftests
Date: Tue, 19 Sep 2017 09:51:27 -0400
Message-ID: <1505829088-1823-2-git-send-email-jbacik@fb.com>
References: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
To: shuah@kernel.org, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:37837 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdISNvc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 09:51:32 -0400
Received: by mail-qk0-f195.google.com with SMTP id r66so2269125qke.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 06:51:31 -0700 (PDT)
In-Reply-To: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>

These self tests are just self contained binaries, they are not run by
any of the scripts in the directory.  This means they need to be marked
with TEST_GEN_PROGS to actually be run, not TEST_GEN_FILES.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
v1->v2:
- Moved msg_zerocopy to TEST_GEN_FILES since it's not runnable in it's current
  state

 tools/testing/selftests/net/Makefile | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 3df542c84610..d86bca991f45 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -5,9 +5,9 @@ CFLAGS += -I../../../../usr/include/
 
 TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh rtnetlink.sh
 TEST_GEN_FILES =  socket
-TEST_GEN_FILES += psock_fanout psock_tpacket
-TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
-TEST_GEN_FILES += reuseport_dualstack msg_zerocopy reuseaddr_conflict
+TEST_GEN_FILES += psock_fanout psock_tpacket msg_zerocopy
+TEST_GEN_PROGS = reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
+TEST_GEN_PROGS += reuseport_dualstack reuseaddr_conflict
 
 include ../lib.mk
 
-- 
2.7.4
