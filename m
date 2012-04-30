From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 1/5] be2net: Fix to not set link speed for disabled functions of a UMC card
Date: Mon, 30 Apr 2012 11:34:01 +0530
Message-ID: <48ac005f-5f84-42f4-a15a-e3156cbb5ad1@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:42944 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751660Ab2D3GFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 02:05:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This renders the interface view somewhat inconsistent from the Host OS POV
considering the rest of the interfaces are showing their respective speeds
based on the bandwidth assigned to them.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 7b06f35..c9ba2cb 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -558,7 +558,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				be_link_status_update(adapter, link_status);
 			if (link_speed)
 				et_speed = link_speed * 10;
-			else
+			else if (link_status)
 				et_speed = convert_to_et_speed(port_speed);
 		} else {
 			et_speed = adapter->phy.forced_port_speed;
-- 
1.5.6.1
