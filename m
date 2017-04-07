From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 12/14] net: typhoon: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:37 +0200
Message-ID: <20170407081739.5243-13-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34516 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755499AbdDGIRu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:50 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
typhoon, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/3com/typhoon.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 084a6d58543a..be823c186517 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -283,7 +283,6 @@ struct typhoon {
 	spinlock_t		command_lock	____cacheline_aligned;
 	struct basic_ring	cmdRing;
 	struct basic_ring	respRing;
-	struct net_device_stats	stats;
 	struct net_device_stats	stats_saved;
 	struct typhoon_shared *	shared;
 	dma_addr_t		shared_dma;
@@ -898,7 +897,7 @@ typhoon_set_rx_mode(struct net_device *dev)
 static int
 typhoon_do_get_stats(struct typhoon *tp)
 {
-	struct net_device_stats *stats = &tp->stats;
+	struct net_device_stats *stats = &tp->dev->stats;
 	struct net_device_stats *saved = &tp->stats_saved;
 	struct cmd_desc xp_cmd;
 	struct resp_desc xp_resp[7];
@@ -951,7 +950,7 @@ static struct net_device_stats *
 typhoon_get_stats(struct net_device *dev)
 {
 	struct typhoon *tp = netdev_priv(dev);
-	struct net_device_stats *stats = &tp->stats;
+	struct net_device_stats *stats = &tp->dev->stats;
 	struct net_device_stats *saved = &tp->stats_saved;
 
 	smp_rmb();
@@ -1991,7 +1990,7 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	tp->card_state = Sleeping;
 	smp_wmb();
 	typhoon_do_get_stats(tp);
-	memcpy(&tp->stats_saved, &tp->stats, sizeof(struct net_device_stats));
+	memcpy(&tp->stats_saved, &tp->dev->stats, sizeof(struct net_device_stats));
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_HALT);
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
-- 
2.12.2
