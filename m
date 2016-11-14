From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v2 4/5] ethtool: Core impl for ETHTOOL_PHY_DOWNSHIFT tunable
Date: Mon, 14 Nov 2016 10:29:19 +0100
Message-ID: <1479115760-1182-5-git-send-email-allan.nielsen@microsemi.com>
References: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0089.outbound.protection.outlook.com ([104.47.38.89]:10753
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752824AbcKNK2k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 05:28:40 -0500
In-Reply-To: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Adding validation support for the ETHTOOL_PHY_DOWNSHIFT. Functional
implementation needs to be done in the individual PHY drivers.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 net/core/ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 61aebdf..e9b45567 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -122,6 +122,7 @@ tunable_strings[__ETHTOOL_TUNABLE_COUNT][ETH_GSTRING_LEN] = {
 static const char
 phy_tunable_strings[__ETHTOOL_PHY_TUNABLE_COUNT][ETH_GSTRING_LEN] = {
 	[ETHTOOL_ID_UNSPEC]     = "Unspec",
+	[ETHTOOL_PHY_DOWNSHIFT]	= "phy-downshift",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
@@ -2435,6 +2436,11 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 static int ethtool_phy_tunable_valid(const struct ethtool_tunable *tuna)
 {
 	switch (tuna->id) {
+	case ETHTOOL_PHY_DOWNSHIFT:
+		if (tuna->len != sizeof(u8) ||
+		    tuna->type_id != ETHTOOL_TUNABLE_U8)
+			return -EINVAL;
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
2.7.3
