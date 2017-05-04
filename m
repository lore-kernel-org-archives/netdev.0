From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 3/3] qede: Fix possible misconfiguration of advertised autoneg value.
Date: Wed, 3 May 2017 23:52:09 -0700
Message-ID: <20170504065209.26106-4-sudarsana.kalluru@cavium.com>
References: <20170504065209.26106-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0078.outbound.protection.outlook.com ([104.47.36.78]:9856
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751400AbdEDGwz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 02:52:55 -0400
In-Reply-To: <20170504065209.26106-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fail the configuration of advertised speed-autoneg value if the config
update is not supported.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
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
