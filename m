From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/11] can: flexcan: fix i.MX28 state transition issue
Date: Thu, 19 Oct 2017 13:19:39 +0200
Message-ID: <20171019111945.13580-6-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Zhu Yi <yi.zhu5@cn.bosch.com>,
        Mark Jonas <mark.jonas@de.bosch.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37569 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752962AbdJSLTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:19:55 -0400
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>

Enable FLEXCAN_QUIRK_BROKEN_PERR_STATE for i.MX28 to report correct
state transitions, especially to error passive.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Zhu Yi <yi.zhu5@cn.bosch.com>
Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v4.11
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index d6ad12744ff1..ed544c44848f 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -285,7 +285,9 @@ static const struct flexcan_devtype_data fsl_p1010_devtype_data = {
 	.quirks = FLEXCAN_QUIRK_BROKEN_WERR_STATE,
 };
 
-static const struct flexcan_devtype_data fsl_imx28_devtype_data;
+static const struct flexcan_devtype_data fsl_imx28_devtype_data = {
+	.quirks = FLEXCAN_QUIRK_BROKEN_PERR_STATE,
+};
 
 static const struct flexcan_devtype_data fsl_imx6q_devtype_data = {
 	.quirks = FLEXCAN_QUIRK_DISABLE_RXFG | FLEXCAN_QUIRK_ENABLE_EACEN_RRS |
-- 
2.14.2
