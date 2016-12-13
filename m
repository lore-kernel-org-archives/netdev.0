From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 07/27] gianfar: remove use of VLAN_TAG_PRESENT
Date: Tue, 13 Dec 2016 01:12:34 +0100 (CET)
Message-ID: <244d34e8fb9a120fa79c40f06e9da7e10c1c0536.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com> (maintainer:FREESCALE
        eTSEC ETHERNET DRIVER (GIANFAR))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50214 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753340AbcLMAMi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:38 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 56588f2..95fa647 100644
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
2.10.2
