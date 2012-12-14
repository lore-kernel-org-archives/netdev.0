From: Amos Kong <akong@redhat.com>
Subject: [Netperf PATCH] output remote_send_size in TCP_MAERTS result
Date: Fri, 14 Dec 2012 18:49:08 +0800
Message-ID: <1355482148-31407-1-git-send-email-akong@redhat.com>
Cc: netdev@vger.kernel.org, Amos Kong <akong@redhat.com>
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359Ab2LNKqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 05:46:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I executed TCP_MAERTS by following command line:
  netperf-2.6.0 -H 192.168.58.23 -l 10 -C -t TCP_MAERTS -- -m 512,1024
The outputed send size is '512'.

When I executed TCP_MAERTS by following command line:
  netperf-2.6.0 -H 192.168.58.23 -l 10 -t TCP_MAERTS -- -m 512,1024
The outputed send size is '1024'.

In TCP_MAERTS test, we should output the remote send size '1024',
this patch fixed this issue.

Reported-by: Wenli Quan <wquan@redhat.com>
Signed-off-by: Amos Kong <akong@redhat.com>
---
 src/nettest_omni.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/src/nettest_omni.c b/src/nettest_omni.c
index 826167a..b0b1500 100644
--- a/src/nettest_omni.c
+++ b/src/nettest_omni.c
@@ -5951,7 +5951,7 @@ Size (bytes)\n\
 		cpu_fmt_1,		/* the format string */
 		rsr_size,		/* remote recvbuf size */
 		lss_size,		/* local sendbuf size */
-		send_size,		/* how large were the recvs */
+		remote_send_size,	/* how large were the recvs */
 		elapsed_time,		/* how long was the test */
 		thruput, 		/* what was the xfer rate */
 		local_cpu_utilization,	/* local cpu */
@@ -5983,7 +5983,7 @@ Size (bytes)\n\
 		tput_fmt_1,		/* the format string */
 		lsr_size, 		/* local recvbuf size */
 		rss_size, 		/* remot sendbuf size */
-		remote_send_size,		/* how large were the recvs */
+		remote_send_size,	/* how large were the recvs */
 		elapsed_time, 		/* how long did it take */
 		thruput,                  /* how fast did it go */
 		((print_headers) ||
-- 
1.7.1
