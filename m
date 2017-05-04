From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net v2 3/3] qede: Fix possible misconfiguration of advertised autoneg value.
Date: Thu, 4 May 2017 08:15:05 -0700
Message-ID: <20170504151505.4407-4-sudarsana.kalluru@cavium.com>
References: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0054.outbound.protection.outlook.com ([104.47.38.54]:55794
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752687AbdEDPPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 11:15:36 -0400
In-Reply-To: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fail the configuration of advertised speed-autoneg value if the config
update is not supported.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index b22753c..172b292 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -493,6 +493,11 @@ static int qede_set_link_ksettings(struct net_device *dev,
 	params.override_flags |= QED_LINK_OVERRIDE_SPEED_ADV_SPEEDS;
 	params.override_flags |= QED_LINK_OVERRIDE_SPEED_AUTONEG;
 	if (base->autoneg == AUTONEG_ENABLE) {
+		if (!(current_link.supported_caps & QED_LM_Autoneg_BIT)) {
+			DP_INFO(edev, "Auto negotiation is not supported\n");
+			return -EOPNOTSUPP;
+		}
+
 		params.autoneg = true;
 		params.forced_speed = 0;
 		QEDE_ETHTOOL_TO_DRV_CAPS(params.adv_speeds, cmd, advertising)
-- 
1.8.3.1
