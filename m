From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/6] qede: Add support for set_phys_id
Date: Mon, 30 Nov 2015 12:25:04 +0200
Message-ID: <1448879106-12321-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:34699 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613AbbK3K0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:20 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 29 +++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 10d80ba..b90d880 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -459,6 +459,34 @@ static int qede_set_channels(struct net_device *dev,
 	return 0;
 }
 
+static int qede_set_phys_id(struct net_device *dev,
+			    enum ethtool_phys_id_state state)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u8 led_state = 0;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return 1;	/* cycle on/off once per second */
+
+	case ETHTOOL_ID_ON:
+		led_state = QED_LED_MODE_ON;
+		break;
+
+	case ETHTOOL_ID_OFF:
+		led_state = QED_LED_MODE_OFF;
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		led_state = QED_LED_MODE_RESTORE;
+		break;
+	}
+
+	edev->ops->common->set_led(edev->cdev, led_state);
+
+	return 0;
+}
+
 static const struct ethtool_ops qede_ethtool_ops = {
 	.get_settings = qede_get_settings,
 	.set_settings = qede_set_settings,
@@ -469,6 +497,7 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_ringparam = qede_get_ringparam,
 	.set_ringparam = qede_set_ringparam,
 	.get_strings = qede_get_strings,
+	.set_phys_id = qede_set_phys_id,
 	.get_ethtool_stats = qede_get_ethtool_stats,
 	.get_sset_count = qede_get_sset_count,
 
-- 
1.9.3
