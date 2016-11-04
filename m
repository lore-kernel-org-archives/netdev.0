From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 4/5] ethtool: Core impl for ETHTOOL_PHY_DOWNSHIFT tunable
Date: Fri, 4 Nov 2016 11:35:41 +0100
Message-ID: <1478255742-25693-5-git-send-email-allan.nielsen@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>,
        "Raju Lakkaraju" <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0062.outbound.protection.outlook.com ([104.47.33.62]:26752
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753494AbcKDLJt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 07:09:49 -0400
In-Reply-To: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Adding validation support for the ETHTOOL_PHY_DOWNSHIFT. Functional
implementation needs to be done in the individual PHY drivers.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 net/core/ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 75f19ab..1a66faa 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2425,6 +2425,11 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
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
