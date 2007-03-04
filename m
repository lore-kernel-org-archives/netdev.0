From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 01/08]: tbf: fix latency printing
Date: Sun,  4 Mar 2007 20:14:55 +0100 (MET)
Message-ID: <20070304191404.22838.45177.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61722 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbXCDTO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:14:56 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: tbf: fix latency printing

The calculated latency is already in usecs, the additional tick2usec
conversion breaks the calculation with jiffies or tsc clock source.

Example:

# tc qdisc add dev dummy0 root tbf latency 20ms burst 10k rate 50mbit
# tc qdisc show dev dummy0
qdisc tbf 8002: rate 50000Kbit burst 10Kb lat 15.4ms 

Fixed:

# tc qdisc show dev dummy0
qdisc tbf 8002: rate 50000Kbit burst 10Kb lat 20ms

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b17ff630348093476b7679b421aba1797f3d6466
tree 95acccdac41e6eeeb0a9b270b43d8e0c747f2524
parent 40076f622e0aacb2b792d3ac1b5d12aa97c4da9c
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 19:31:16 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 19:31:16 +0100

 tc/q_tbf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index b8251cb..b50519f 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -251,7 +251,7 @@ static int tbf_print_opt(struct qdisc_ut
 		if (lat2 > latency)
 			latency = lat2;
 	}
-	fprintf(f, "lat %s ", sprint_usecs(tc_core_tick2usec(latency), b1));
+	fprintf(f, "lat %s ", sprint_usecs(latency, b1));
 
 	return 0;
 }
