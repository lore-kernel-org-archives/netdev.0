From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 4/6] be2net: fix to allow port beacon when
 device is closed
Date: Mon, 30 Nov 2009 09:26:56 +0530
Message-ID: <20091130035646.GA15530@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29515 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753267AbZK3D4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 22:56:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

port identification/beaconing is failing if device open has not been done.
Fixing it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index e8f9283..9eabed4 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -380,9 +380,6 @@ be_phys_id(struct net_device *netdev, u32 data)
 	int status;
 	u32 cur;
 
-	if (!netif_running(netdev))
-		return 0;
-
 	be_cmd_get_beacon_state(adapter, adapter->port_num, &cur);
 
 	if (cur == BEACON_STATE_ENABLED)
-- 
1.6.3.3

