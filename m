From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPv6] SNMP: Increment OutNoRoutes when connecting to
 unreachable network
Date: Thu, 6 Dec 2007 15:29:48 +0900
Message-ID: <20071206152948.1f593cd5.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33068 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbXLFGad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 01:30:33 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB66UNDK001317
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 01:30:23 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB66UNQU065300
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2007 23:30:23 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB66UM72028743
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2007 23:30:22 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 stack doesn't increment OutNoRoutes counter when IP datagrams
is being discarded because no route could be found to transmit them
to their destination. IPv6 stack should increment the counter.
Incidentally, IPv4 stack increments that counter in such situation.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv6/ip6_output.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 89cca7c..388a098 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -960,6 +960,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	return 0;
 
 out_err_release:
+	if (err == -ENETUNREACH)
+		IP6_INC_STATS_BH(NULL, IPSTATS_MIB_OUTNOROUTES);
 	dst_release(*dst);
 	*dst = NULL;
 	return err;
-- 
1.5.3.4

