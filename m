From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPv4] SNMP: Refer correct memory location to display ICMP
 out-going statistics
Date: Fri, 26 Oct 2007 10:59:28 +0900
Message-ID: <20071026105928.d56cd244.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David L Stevens <dlstevens@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53914 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbXJZB7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 21:59:33 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9Q1xXGl016052
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 21:59:33 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9Q1xXlZ128352
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 19:59:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9Q1xW4h019799
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 19:59:33 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While displaying ICMP out-going statistics as Out<name> counters in
/proc/net/snmp, the memory location for ICMP in-coming statistics
was referred by mistake.

Acked-by: David L Stevens <dlstevens@us.ibm.com> 
Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index fd16cb8..b7f7f8a 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -312,7 +312,7 @@ static void icmp_put(struct seq_file *seq)
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			snmp_fold_field((void **) icmpmsg_statistics,
-				icmpmibmap[i].index));
+				icmpmibmap[i].index | 0x100));
 }
 
 /*
-- 
1.5.3.4

