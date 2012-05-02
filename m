From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 1/5] be2net: Fix to not set link speed for disabled functions of a UMC card
Date: Wed, 2 May 2012 19:10:16 +0530
Message-ID: <22f64dbf-b01b-4e79-9d50-86138b289b2a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:19201 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127Ab2EBNld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 09:41:33 -0400
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
