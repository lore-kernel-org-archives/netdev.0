From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/20] ixgbe: cleanup ixgbe_get_drvinfo to be
	extra careful with buffer boundaries
Date: Thu, 19 Aug 2010 16:33:16 -0700
Message-ID: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:46839
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0HSXdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:33:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Make the code in ixgbe_get_drvinfo more protected against buffer overflow
boundaries by using snprintf and sizeof with snprintf.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index dcebc82..fb6d8e8 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -820,16 +820,19 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
 
-	strncpy(drvinfo->driver, ixgbe_driver_name, 32);
-	strncpy(drvinfo->version, ixgbe_driver_version, 32);
-
-	sprintf(firmware_version, "%d.%d-%d",
-	        (adapter->eeprom_version & 0xF000) >> 12,
-	        (adapter->eeprom_version & 0x0FF0) >> 4,
-	        adapter->eeprom_version & 0x000F);
-
-	strncpy(drvinfo->fw_version, firmware_version, 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strncpy(drvinfo->driver, ixgbe_driver_name, sizeof(drvinfo->driver));
+	strncpy(drvinfo->version, ixgbe_driver_version,
+	        sizeof(drvinfo->version));
+
+	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
+	         (adapter->eeprom_version & 0xF000) >> 12,
+	         (adapter->eeprom_version & 0x0FF0) >> 4,
+	         adapter->eeprom_version & 0x000F);
+
+	strncpy(drvinfo->fw_version, firmware_version,
+	        sizeof(drvinfo->fw_version));
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
+	        sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = IXGBE_STATS_LEN;
 	drvinfo->testinfo_len = IXGBE_TEST_LEN;
 	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);

