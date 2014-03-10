From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 07/31] iw_cxgb4: Allow loopback connections
Date: Mon, 10 Mar 2014 22:38:04 +0530
Message-ID: <1394471308-4304-8-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2938 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753468AbaCJRRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:17:19 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

find_route() must treat loopback as a valid
egress interface.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index d286bde..360807e 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -400,7 +400,8 @@ static struct dst_entry *find_route(struct c4iw_dev *dev, __be32 local_ip,
 	n = dst_neigh_lookup(&rt->dst, &peer_ip);
 	if (!n)
 		return NULL;
-	if (!our_interface(dev, n->dev)) {
+	if (!our_interface(dev, n->dev) &&
+	    !(n->dev->flags & IFF_LOOPBACK)) {
 		dst_release(&rt->dst);
 		return NULL;
 	}
-- 
1.8.4
