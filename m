From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 1/3] be2net: Bug Fix while accounting of multicast frames
	during netdev stats update
Date: Mon, 5 Oct 2009 17:51:51 +0530
Message-ID: <20091005122140.GA22946@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:62172 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751287AbZJEMWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:22:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While updating the statistics to be passed via the get_stats,
tx multicast frames were being accounted instead of rx multicast frames.
This patch fixes the bug. This patch is against the net-2.6 tree.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 2f9b501..e86b2f3 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -197,7 +197,7 @@ void netdev_stats_update(struct be_adapter *adapter)
 	/* no space available in linux */
 	dev_stats->tx_dropped = 0;
 
-	dev_stats->multicast = port_stats->tx_multicastframes;
+	dev_stats->multicast = port_stats->rx_multicast_frames;
 	dev_stats->collisions = 0;
 
 	/* detailed tx_errors */
-- 
1.6.0.4

