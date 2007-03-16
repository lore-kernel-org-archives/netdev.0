From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Fix warning
Date: Fri, 16 Mar 2007 14:35:04 +0100
Message-ID: <45FA9D08.4010804@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050309060909060601080307"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53966 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbXCPNfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 09:35:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050309060909060601080307
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix a warning introduced by my patches, seems like I didn't pay
enough attention ..



--------------050309060909060601080307
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Fix warning

net/sched/sch_api.c: In function 'psched_show':
net/sched/sch_api.c:1219: warning: format '%08x' expects type 'unsigned int', but argument 6 has type 's64'

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4637e33149600f53399e4f36c89f6818671ebc87
tree 966f51f002a2ed08d3a3a6c2981429c63e8ce7b0
parent 20bac6a57d8d37deecd8b8101269542fe2c625b0
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 14:21:37 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 14:21:37 +0100

 net/sched/sch_api.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 047ae62..ecbdc6b 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1216,7 +1216,8 @@ static int psched_show(struct seq_file *
 {
 	seq_printf(seq, "%08x %08x %08x %08x\n",
 		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
-		   1000000, (u32)NSEC_PER_SEC/ktime_to_ns(KTIME_MONOTONIC_RES));
+		   1000000,
+		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(KTIME_MONOTONIC_RES));
 
 	return 0;
 }

--------------050309060909060601080307--
