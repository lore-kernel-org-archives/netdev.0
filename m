From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Thu, 6 Dec 2007 15:31:05 +0900
Message-ID: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36003 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbXLFGbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 01:31:17 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB66Ws1d021082
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 01:32:54 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB66VCVg448278
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 01:31:12 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB66VCax001135
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 01:31:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 stack doesn't reply any ICMP destination unreachable message
with net unreachable code when IP detagrams are being discarded
because of no route could be found in the forwarding path.
Incidentally, IPv6 stack replies such ICMPv6 message in the similar
situation.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/route.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6714bbc..ba85ec9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1375,6 +1375,7 @@ static int ip_error(struct sk_buff *skb)
 			break;
 		case ENETUNREACH:
 			code = ICMP_NET_UNREACH;
+			IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
 			break;
 		case EACCES:
 			code = ICMP_PKT_FILTERED;
@@ -2004,6 +2005,7 @@ no_route:
 	RT_CACHE_STAT_INC(in_no_route);
 	spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	res.type = RTN_UNREACHABLE;
+	err = -ENETUNREACH;
 	goto local_input;
 
 	/*
-- 
1.5.3.4

