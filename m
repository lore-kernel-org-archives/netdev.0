From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/3] be2net: fix speed displayed by ethtool on
 certain SKUs
Date: Thu, 26 Apr 2012 20:42:39 -0500
Message-ID: <20120427014239.GA742@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:56116 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758102Ab2D0Bmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 21:42:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

logical speed returned by link_status_query needs to be multiplied by 10.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 0c6f06e..7b06f35 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -557,7 +557,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			if (!status)
 				be_link_status_update(adapter, link_status);
 			if (link_speed)
-				et_speed = link_speed;
+				et_speed = link_speed * 10;
 			else
 				et_speed = convert_to_et_speed(port_speed);
 		} else {
-- 
1.7.5.4
