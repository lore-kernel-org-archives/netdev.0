From: Somnath Kotur <Somnath.Kotur@emulex.com>
Subject: [PATCH net-next 1/5] be2net: Fix to not set link speed for disabled functions of a UMC card
Date: Thu, 26 Apr 2012 19:57:31 +0530
Message-ID: <1dbcfb89-109d-42e6-9e1d-412a9d3ab869@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:47275 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753609Ab2DZOhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 10:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

This renders the interface view somewhat inconsistent from the Host OS POV
considering the rest of the interfaces are showing their respective speeds
based on the bandwidth assigned to them.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 0c6f06e..a00983e 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -558,7 +558,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				be_link_status_update(adapter, link_status);
 			if (link_speed)
 				et_speed = link_speed;
-			else
+			else if (link_status)
 				et_speed = convert_to_et_speed(port_speed);
 		} else {
 			et_speed = adapter->phy.forced_port_speed;
-- 
1.5.6.1
