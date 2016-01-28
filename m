From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Exclude rx_drop_pkts hw counter from the stack's rx_dropped counter.
Date: Thu, 28 Jan 2016 03:11:21 -0500
Message-ID: <1453968682-10014-3-git-send-email-mchan@broadcom.com>
References: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:3533 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934823AbcA1ILZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 03:11:25 -0500
In-Reply-To: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This hardware counter is misleading as it counts dropped packets that
don't match the hardware filters for unicast/broadcast/multicast.  We
will still report this counter in ethtool -S for diagnostics purposes.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 17dcacd..ebc5413 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4819,8 +4819,6 @@ bnxt_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 
 		stats->multicast += le64_to_cpu(hw_stats->rx_mcast_pkts);
 
-		stats->rx_dropped += le64_to_cpu(hw_stats->rx_drop_pkts);
-
 		stats->tx_dropped += le64_to_cpu(hw_stats->tx_drop_pkts);
 	}
 
-- 
1.8.3.1
