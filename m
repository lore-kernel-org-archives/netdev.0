From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/24] igb: Fix strncpy calls to be safe per source code review tools
Date: Thu,  3 Mar 2011 05:03:28 -0800
Message-ID: <1299157429-15878-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37146 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758183Ab1CCNET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:19 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This fix changes the remaining calls to strncpy that have not yet
been changed to use the "sizeof(buf) - 1" syntax rather than just
a number for buffer size.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_ethtool.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 16bbd49..61f7849 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -727,8 +727,9 @@ static void igb_get_drvinfo(struct net_device *netdev,
 	char firmware_version[32];
 	u16 eeprom_data;
 
-	strncpy(drvinfo->driver,  igb_driver_name, 32);
-	strncpy(drvinfo->version, igb_driver_version, 32);
+	strncpy(drvinfo->driver,  igb_driver_name, sizeof(drvinfo->driver) - 1);
+	strncpy(drvinfo->version, igb_driver_version,
+		sizeof(drvinfo->version) - 1);
 
 	/* EEPROM image version # is reported as firmware version # for
 	 * 82575 controllers */
@@ -738,8 +739,10 @@ static void igb_get_drvinfo(struct net_device *netdev,
 		(eeprom_data & 0x0FF0) >> 4,
 		eeprom_data & 0x000F);
 
-	strncpy(drvinfo->fw_version, firmware_version, 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strncpy(drvinfo->fw_version, firmware_version,
+		sizeof(drvinfo->fw_version) - 1);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info) - 1);
 	drvinfo->n_stats = IGB_STATS_LEN;
 	drvinfo->testinfo_len = IGB_TEST_LEN;
 	drvinfo->regdump_len = igb_get_regs_len(netdev);
-- 
1.7.4

