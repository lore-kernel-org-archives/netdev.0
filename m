From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: intel: e100: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  7 Jan 2017 23:18:07 +0100
Message-ID: <1483827487-20355-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33136 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754003AbdAGWSQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:18:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/intel/e100.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 25c6dfd..04e9392 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2426,19 +2426,21 @@ static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
 #define E100_82552_LED_ON       0x000F /* LEDTX and LED_RX both on */
 #define E100_82552_LED_OFF      0x000A /* LEDTX and LED_RX both off */
 
-static int e100_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+static int e100_get_link_ksettings(struct net_device *netdev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct nic *nic = netdev_priv(netdev);
-	return mii_ethtool_gset(&nic->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&nic->mii, cmd);
 }
 
-static int e100_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+static int e100_set_link_ksettings(struct net_device *netdev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct nic *nic = netdev_priv(netdev);
 	int err;
 
 	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, BMCR_RESET);
-	err = mii_ethtool_sset(&nic->mii, cmd);
+	err = mii_ethtool_set_link_ksettings(&nic->mii, cmd);
 	e100_exec_cb(nic, NULL, e100_configure);
 
 	return err;
@@ -2741,8 +2743,6 @@ static void e100_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 }
 
 static const struct ethtool_ops e100_ethtool_ops = {
-	.get_settings		= e100_get_settings,
-	.set_settings		= e100_set_settings,
 	.get_drvinfo		= e100_get_drvinfo,
 	.get_regs_len		= e100_get_regs_len,
 	.get_regs		= e100_get_regs,
@@ -2763,6 +2763,8 @@ static void e100_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	.get_ethtool_stats	= e100_get_ethtool_stats,
 	.get_sset_count		= e100_get_sset_count,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings	= e100_get_link_ksettings,
+	.set_link_ksettings	= e100_set_link_ksettings,
 };
 
 static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-- 
1.7.4.4
