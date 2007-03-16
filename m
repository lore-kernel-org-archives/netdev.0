From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 11/10]: Export real timer resolution in /proc/net/psched
Date: Fri, 16 Mar 2007 08:21:58 +0100
Message-ID: <45FA4596.5050206@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020607080202040009020302"
Cc: devik@cdi.cz, shemminger@linux-foundation.org,
	Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46862 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbXCPHWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 03:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020607080202040009020302
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------020607080202040009020302
Content-Type: text/x-diff;
 name="11.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11.diff"

[NET_SCHED]: Export real timer resolution in /proc/net/psched

The timer resolution exported in /proc/net/psched is used by userspace to
calculate HTB's burst values. Currently it is set to HZ, since we're now
using hrtimers, use KTIME_MONOTONIC_RES, which makes HTB use smaller burst
values.

This patch also affects libnl, which incorrectly uses this value for
the SFQ perturbation parameter, which is always in seconds, and some
routing cache values, which are in USER_HZ, so both cases are broken
anyway.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d80d8513f4cc52674ee37d7453b420092b556bb4
tree 5de9494bf9d17180c61cd313d96738400befbd6a
parent 32b945035419c2d458cd0bf7072acb335e5c4044
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 08:20:44 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 08:20:44 +0100

 net/sched/sch_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6bc395c..047ae62 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1216,7 +1216,7 @@ static int psched_show(struct seq_file *
 {
 	seq_printf(seq, "%08x %08x %08x %08x\n",
 		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
-		   1000000, HZ);
+		   1000000, (u32)NSEC_PER_SEC/ktime_to_ns(KTIME_MONOTONIC_RES));
 
 	return 0;
 }

--------------020607080202040009020302--
