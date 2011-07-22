From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ixgbe: only enable WoL for magic packet by default
Date: Thu, 21 Jul 2011 19:01:17 -0700
Message-ID: <1311300078-12876-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Martin Wilck <martin.wilck@ts.fujitsu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56055 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160Ab1GVCB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 22:01:26 -0400
In-Reply-To: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

Martin Wilck <martin.wilck@ts.fujitsu.com> reported that systems using
the ixgbe-driver that were capable of WoL were rebooting almost as soon
as they were shut down.  This is because the default WoL settings
enabled magic packet, broadcast, unicast, and multicast.

Other Intel devices seem to use the stored eeprom value for initial WoL
capabilities.  The 82578DM (e1000e) and 82576 (igb) the devices I looked
at had only the magic packet enabled in the eeprom, so that seems
appropriate on ixgbe-based devices as well.  I set the WoL options on my
82578DM to be the same default as the ixgbe devices (umbg) and saw the
same as Martin -- almost as soon as my box shutdown, it booted again.

This patch changes the default to only be the magic packet.  This is the
same as the default for most Intel and non-Intel hardware currently
upstream.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
CC: Martin Wilck <martin.wilck@ts.fujitsu.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d448124..3f1715b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7515,18 +7515,15 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	case IXGBE_DEV_ID_82599_SFP:
 		/* Only this subdevice supports WOL */
 		if (pdev->subsystem_device == IXGBE_SUBDEV_ID_82599_SFP)
-			adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
-			                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+			adapter->wol = IXGBE_WUFC_MAG;
 		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
 		if (pdev->subsystem_device != IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ)
-			adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
-			                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+			adapter->wol = IXGBE_WUFC_MAG;
 		break;
 	case IXGBE_DEV_ID_82599_KX4:
-		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
-				IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+		adapter->wol = IXGBE_WUFC_MAG;
 		break;
 	default:
 		adapter->wol = 0;
-- 
1.7.6

