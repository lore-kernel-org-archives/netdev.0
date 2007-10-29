From: David Stevens <dlstevens@us.ibm.com>
Subject: Fw: [PATCH] [IPv4] SNMP: Refer correct memory location to display ICMP
 out-going statistics
Date: Mon, 29 Oct 2007 13:54:50 -0700
Message-ID: <OF3783F25C.645FCABB-ON88257383.00729813-88257383.0072C869@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55648 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbXJ2Uyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 16:54:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9TKsqiD029042
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 16:54:52 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9TKsqpC065526
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:54:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9TKsqE9014282
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:54:52 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,
        I didn't see a response for this one... in case it fell through 
the
cracks. Just want to make sure my bone-headed error doesn't hang
around too long. :-)

                                                +-DLS

----- Forwarded by David Stevens/Beaverton/IBM on 10/29/2007 01:51 PM 
-----

Mitsuru Chinen <mitch@linux.vnet.ibm.com> 
Sent by: netdev-owner@vger.kernel.org
10/25/2007 06:59 PM

To
netdev@vger.kernel.org
cc
David Stevens/Beaverton/IBM@IBMUS
Subject
[PATCH] [IPv4] SNMP: Refer correct memory location to display ICMP 
out-going statistics






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
                                                 snmp_fold_field((void **) 
icmpmsg_statistics,
- icmpmibmap[i].index));
+ icmpmibmap[i].index | 0x100));
 }
 
 /*
-- 
1.5.3.4

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

