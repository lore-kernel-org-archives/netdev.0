From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] ixgbe: only enable WoL for magic packet by default
Date: Thu,  7 Apr 2011 10:41:55 -0400
Message-ID: <1302187315-16487-1-git-send-email-andy@greyhouse.net>
Cc: martin.wilck@ts.fujitsu.com, jeffrey.t.kirsher@intel.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826Ab1DGOkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 10:40:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 
---
 drivers/net/ixgbe/ixgbe_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f17e4a7..379b465 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7439,18 +7439,15 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
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
