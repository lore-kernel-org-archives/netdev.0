From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPv4] Add strict check for replying net unreachable
 message
Date: Fri, 7 Dec 2007 13:24:18 +0900
Message-ID: <20071207132418.d19d2f0e.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rami Rosen <roszenrami@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:59874 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbXLGEYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 23:24:33 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB74OUvu014516
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 23:24:30 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB74OUtT129946
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 23:24:30 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB74OUPU002770
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 23:24:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch `Reply net unreachable ICMP message' had a bug.
A route whose type is blockhole or prohibit type is treated as
unreachable type. The case where err is set to ENETUNREACH should
be that no route is found in the routing table only.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/route.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8a79f74..d2bc614 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1882,7 +1882,8 @@ no_route:
 	RT_CACHE_STAT_INC(in_no_route);
 	spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	res.type = RTN_UNREACHABLE;
-	err = -ENETUNREACH;
+	if (err == -ESRCH)
+		err = -ENETUNREACH;
 	goto local_input;
 
 	/*
-- 
1.5.3.4

