From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/4] bnx2: Use proper counter for
 net_device_stats->multicast.
Date: Mon, 19 Jul 2010 17:15:02 -0700
Message-ID: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2795 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757616Ab0GTALu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 20:11:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were using the wrong tx multicast counter instead of the rx multicast
counter.

Reported-by: Peter Snellman <peter.snellman@cinnober.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ce3217b..deb7f83 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6631,7 +6631,7 @@ bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		GET_64BIT_NET_STATS(stat_IfHCOutOctets);
 
 	net_stats->multicast =
-		GET_64BIT_NET_STATS(stat_IfHCOutMulticastPkts);
+		GET_64BIT_NET_STATS(stat_IfHCInMulticastPkts);
 
 	net_stats->collisions =
 		GET_32BIT_NET_STATS(stat_EtherStatsCollisions);
-- 
1.6.4.GIT


