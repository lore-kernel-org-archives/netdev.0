From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] r8169: Add support for restarting auto-negotiation
Date: Sat,  3 Dec 2016 12:01:19 -0800
Message-ID: <20161203200119.1474-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, hau@realtek.com, romieu@fr.zoreil.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Realtek linux nic maintainers <nic_swsd@realtek.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement ethtooll::nway_restart by utilizing mii_nway_restart.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2830190aaace..f9b97f5946f8 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2344,6 +2344,13 @@ static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
+static int rtl8169_nway_reset(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	return mii_nway_restart(&tp->mii);
+}
+
 static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
@@ -2359,6 +2366,7 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_sset_count		= rtl8169_get_sset_count,
 	.get_ethtool_stats	= rtl8169_get_ethtool_stats,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.nway_reset		= rtl8169_nway_reset,
 };
 
 static void rtl8169_get_mac_version(struct rtl8169_private *tp,
-- 
2.9.3
