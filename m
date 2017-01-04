From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next] gianfar: remove use of VLAN_TAG_PRESENT
Date: Wed,  4 Jan 2017 01:07:58 +0100 (CET)
Message-ID: <8be654b2c6cd24a12a6e94f914df45d1dd9eef54.1483487887.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37238 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762094AbdADAID (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:08:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
Reviewed-by: Claudiu Manoil <claudiu.manoil@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index a93e0199c369..fd5110dd13b6 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1155,11 +1155,9 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 		prio = vlan_tci_prio(rule);
 		prio_mask = vlan_tci_priom(rule);
 
-		if (cfi == VLAN_TAG_PRESENT && cfi_mask == VLAN_TAG_PRESENT) {
-			vlan |= RQFPR_CFI;
-			vlan_mask |= RQFPR_CFI;
-		} else if (cfi != VLAN_TAG_PRESENT &&
-			   cfi_mask == VLAN_TAG_PRESENT) {
+		if (cfi_mask) {
+			if (cfi)
+				vlan |= RQFPR_CFI;
 			vlan_mask |= RQFPR_CFI;
 		}
 	}
-- 
2.11.0
