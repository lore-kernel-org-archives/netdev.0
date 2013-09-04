From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH] icplus: Use netif_running to determine device state
Date: Wed,  4 Sep 2013 11:26:01 -0700
Message-ID: <1378319161-18850-1-git-send-email-jdmason@kudzu.us>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Sorbica Shieh <sorbica@icplus.com.tw>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:62623 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab3IDSZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:25:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so765539pab.21
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 11:25:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the __LINK_STATE_START check to verify the device is running, in
favor of netif_running().  netif_running() performs the same check of
__LINK_STATE_START, so the code should behave the same.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
---
 drivers/net/ethernet/icplus/ipg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 1fde90b..bdf5023 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -1004,7 +1004,7 @@ static struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
 	/* Check to see if the NIC has been initialized via nic_open,
 	 * before trying to read statistic registers.
 	 */
-	if (!test_bit(__LINK_STATE_START, &dev->state))
+	if (!netif_running(dev))
 		return &sp->stats;
 
 	sp->stats.rx_packets += ipg_r32(IPG_FRAMESRCVDOK);
-- 
1.7.10.4
