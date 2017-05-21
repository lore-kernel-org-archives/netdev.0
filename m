From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 09/10] qede: Support 1G advertisment.
Date: Sun, 21 May 2017 12:11:00 +0300
Message-ID: <1495357860-28280-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>,
        "Sudarsana Reddy Kalluru" <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0060.outbound.protection.outlook.com ([104.47.32.60]:19376
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752959AbdEUJMN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:12:13 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

Some variants of adapters support the 1G speed capability. Need to
allow the configuration of 1G speed if adapter supports it.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 47ec4f3..6c76a12 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -506,6 +506,14 @@ static int qede_set_link_ksettings(struct net_device *dev,
 		params.autoneg = false;
 		params.forced_speed = base->speed;
 		switch (base->speed) {
+		case SPEED_1000:
+			if (!(current_link.supported_caps &
+			      QED_LM_1000baseT_Full_BIT)) {
+				DP_INFO(edev, "1G speed not supported\n");
+				return -EINVAL;
+			}
+			params.adv_speeds = QED_LM_1000baseT_Full_BIT;
+			break;
 		case SPEED_10000:
 			if (!(current_link.supported_caps &
 			      QED_LM_10000baseKR_Full_BIT)) {
-- 
1.9.3
