From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] RDMA/CMA: Use neigh_event_send() to initiate neighbour discovery.
Date: Wed, 12 Sep 2007 05:00:25 -0500
Message-ID: <20070912100025.3190.89259.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:46887 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753954AbXILKAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:00:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


RDMA/CMA: Use neigh_event_send() to initiate neighbour discovery.

Calling arp_send() to initiate neighbour discovery (ND) doesn't do the
full ND protocol.  Namely, it doesn't handle retransmitting the arp
request if it is dropped. The function neigh_event_send() does all this.
Without doing full ND, rdma address resolution fails in the presence of
dropped arp bcast packets.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/core/addr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index c5c33d3..5381c80 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -161,8 +161,7 @@ static void addr_send_arp(struct sockadd
 	if (ip_route_output_key(&rt, &fl))
 		return;
 
-	arp_send(ARPOP_REQUEST, ETH_P_ARP, rt->rt_gateway, rt->idev->dev,
-		 rt->rt_src, NULL, rt->idev->dev->dev_addr, NULL);
+	neigh_event_send(rt->u.dst.neighbour, NULL);
 	ip_rt_put(rt);
 }
 
