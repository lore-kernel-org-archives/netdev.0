From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] samples/bpf: fix warnings in xdp_monitor_user
Date: Sun,  1 Oct 2017 14:07:34 -0700
Message-ID: <20171001210734.27010-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:48109 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdJAVHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 17:07:44 -0400
Received: by mail-pg0-f43.google.com with SMTP id d8so2052368pgt.4
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 14:07:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make local functions static to fix

  HOSTCC  samples/bpf/xdp_monitor_user.o
samples/bpf/xdp_monitor_user.c:64:7: warning: no previous prototype for ‘gettime’ [-Wmissing-prototypes]
 __u64 gettime(void)
       ^~~~~~~
samples/bpf/xdp_monitor_user.c:209:6: warning: no previous prototype for ‘print_bpf_prog_info’ [-Wmissing-prototypes]
 void print_bpf_prog_info(void)
      ^~~~~~~~~~~~~~~~~~~
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 samples/bpf/xdp_monitor_user.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/xdp_monitor_user.c b/samples/bpf/xdp_monitor_user.c
index b51b4f5e3257..c5ab8b776973 100644
--- a/samples/bpf/xdp_monitor_user.c
+++ b/samples/bpf/xdp_monitor_user.c
@@ -61,7 +61,7 @@ static void usage(char *argv[])
 }
 
 #define NANOSEC_PER_SEC 1000000000 /* 10^9 */
-__u64 gettime(void)
+static __u64 gettime(void)
 {
 	struct timespec t;
 	int res;
@@ -206,7 +206,7 @@ static void stats_poll(int interval, bool err_only)
 	}
 }
 
-void print_bpf_prog_info(void)
+static void print_bpf_prog_info(void)
 {
 	int i;
 
-- 
2.11.0
