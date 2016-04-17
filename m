From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/5] qed: add support for link pause configuration.
Date: Sun, 17 Apr 2016 22:26:34 +0300
Message-ID: <1460921195-23352-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10751 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831AbcDQT0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 15:26:53 -0400
In-Reply-To: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

The APIs for making this sort of configuration [e.g., via ethtool] are
already present in qede, but the current configuration flow in qed doesn't
respect it.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index d189871..1918b83 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -962,6 +962,20 @@ static int qed_set_link(struct qed_dev *cdev,
 	}
 	if (params->override_flags & QED_LINK_OVERRIDE_SPEED_FORCED_SPEED)
 		link_params->speed.forced_speed = params->forced_speed;
+	if (params->override_flags & QED_LINK_OVERRIDE_PAUSE_CONFIG) {
+		if (params->pause_config & QED_LINK_PAUSE_AUTONEG_ENABLE)
+			link_params->pause.autoneg = true;
+		else
+			link_params->pause.autoneg = false;
+		if (params->pause_config & QED_LINK_PAUSE_RX_ENABLE)
+			link_params->pause.forced_rx = true;
+		else
+			link_params->pause.forced_rx = false;
+		if (params->pause_config & QED_LINK_PAUSE_TX_ENABLE)
+			link_params->pause.forced_tx = true;
+		else
+			link_params->pause.forced_tx = false;
+	}
 
 	rc = qed_mcp_set_link(hwfn, ptt, params->link_up);
 
-- 
1.9.3
