From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Show timer resolution instead of clock resolution in
 /proc/net/psched
Date: Wed, 10 Oct 2007 16:34:24 +0200
Message-ID: <470CE2F0.20103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050107090605070600030502"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62889 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbXJJOe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:34:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050107090605070600030502
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Fix incorrect HTB burst rate calculation in userspace when
clock and timer resolution differ. I guess this should go
in stable 2.6.22/23 as well.


--------------050107090605070600030502
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Show timer resolution instead of clock resolution in /proc/net/psched

The fourth parameter of /proc/net/psched is supposed to show the timer resultion
and is used by HTB userspace to calculate the necessary burst rate. Currently
we show the clock resolution, which results in a too low burst rate when the
two differ.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a3885788169f2f70634f8142344e5131ccf32595
tree 62bcf28c9706547228521dc4402ebea273326331
parent 0e52ab8ceb41df2104279938484267ab474286d1
author Patrick McHardy <kaber@trash.net> Wed, 10 Oct 2007 16:29:14 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 10 Oct 2007 16:29:14 +0200

 net/sched/sch_api.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index dee0d5f..8f1bcf6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1225,10 +1225,13 @@ EXPORT_SYMBOL(tcf_destroy_chain);
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
+	struct timespec ts;
+
+	hrtimer_get_res(CLOCK_MONOTONIC, &ts);
 	seq_printf(seq, "%08x %08x %08x %08x\n",
 		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
 		   1000000,
-		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(KTIME_MONOTONIC_RES));
+		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(timespec_to_ktime(ts)));
 
 	return 0;
 }

--------------050107090605070600030502--
