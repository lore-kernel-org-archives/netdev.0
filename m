From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 2/6] [IPV4] SNMP: Support InNoRoutes
Date: Tue, 17 Apr 2007 20:13:15 +0900
Message-ID: <20070417201315.54ba847c.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52773 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753807AbXDQLN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:13:28 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HBDShv027349
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HBDRuQ556622
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HBDLTI027081
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:21 -0400
In-Reply-To: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An IP datagram which is being discarded because of no routes in the
forwarding path should be counted as InNoRoutes.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/ip_input.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 324e7e0..63ab523 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -340,6 +340,8 @@ static inline int ip_rcv_finish(struct s
 		if (unlikely(err)) {
 			if (err == -EHOSTUNREACH)
 				IP_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+			else if (err == -ENETUNREACH)
+				IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
 			goto drop;
 		}
 	}
-- 
1.4.3.4

