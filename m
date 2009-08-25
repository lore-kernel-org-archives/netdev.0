From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: Fix isues while reporting 8259x backplane
	link capabilities
Date: Tue, 25 Aug 2009 07:47:11 -0700
Message-ID: <20090825144709.15560.28811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:48142 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755025AbZHYOr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 10:47:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Fix ethtool get_settings logic to report 10G & 1G advertised and
supported link modes in all 8259x 10G backplane connection types
except for 82598EB BX network connection type.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index dd221bb..1444ec5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -169,23 +169,20 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		}
 	} else if (hw->phy.media_type == ixgbe_media_type_backplane) {
 		/* Set as FIBRE until SERDES defined in kernel */
-		switch (hw->device_id) {
-		case IXGBE_DEV_ID_82598:
-			ecmd->supported |= (SUPPORTED_1000baseT_Full |
-				SUPPORTED_FIBRE);
-			ecmd->advertising = (ADVERTISED_10000baseT_Full |
-				ADVERTISED_1000baseT_Full |
-				ADVERTISED_FIBRE);
-			ecmd->port = PORT_FIBRE;
-			break;
-		case IXGBE_DEV_ID_82598_BX:
+		if (hw->device_id == IXGBE_DEV_ID_82598_BX) {
 			ecmd->supported = (SUPPORTED_1000baseT_Full |
 					   SUPPORTED_FIBRE);
 			ecmd->advertising = (ADVERTISED_1000baseT_Full |
 					     ADVERTISED_FIBRE);
 			ecmd->port = PORT_FIBRE;
 			ecmd->autoneg = AUTONEG_DISABLE;
-			break;
+		} else {
+			ecmd->supported |= (SUPPORTED_1000baseT_Full |
+					    SUPPORTED_FIBRE);
+			ecmd->advertising = (ADVERTISED_10000baseT_Full |
+					     ADVERTISED_1000baseT_Full |
+					     ADVERTISED_FIBRE);
+			ecmd->port = PORT_FIBRE;
 		}
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;

