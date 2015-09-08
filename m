From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/2] driver: net: xgene: Add support for 2nd 10GbE port
Date: Tue,  8 Sep 2015 15:50:26 -0700
Message-ID: <1441752627-9326-2-git-send-email-isubramanian@apm.com>
References: <1441752627-9326-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33802 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbbIHWug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 18:50:36 -0400
Received: by padhy16 with SMTP id hy16so134151933pad.1
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 15:50:36 -0700 (PDT)
In-Reply-To: <1441752627-9326-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding support for the second 10GbE port on APM X-Gene SoC

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  3 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 16 ++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  5 +++++
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index cfa3704..21749f0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -107,7 +107,8 @@ static void xgene_enet_set_ring_state(struct xgene_enet_desc_ring *ring)
 {
 	xgene_enet_ring_set_type(ring);
 
-	if (xgene_enet_ring_owner(ring->id) == RING_OWNER_ETH0)
+	if (xgene_enet_ring_owner(ring->id) == RING_OWNER_ETH0 ||
+	    xgene_enet_ring_owner(ring->id) == RING_OWNER_ETH1)
 		xgene_enet_ring_set_recombbuf(ring);
 
 	xgene_enet_ring_init(ring);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index e47298f..6b1846d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1305,10 +1305,17 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 			pdata->ring_num = START_RING_NUM_0;
 			break;
 		case 1:
-			pdata->cpu_bufnum = START_CPU_BUFNUM_1;
-			pdata->eth_bufnum = START_ETH_BUFNUM_1;
-			pdata->bp_bufnum = START_BP_BUFNUM_1;
-			pdata->ring_num = START_RING_NUM_1;
+			if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+				pdata->cpu_bufnum = XG_START_CPU_BUFNUM_1;
+				pdata->eth_bufnum = XG_START_ETH_BUFNUM_1;
+				pdata->bp_bufnum = XG_START_BP_BUFNUM_1;
+				pdata->ring_num = XG_START_RING_NUM_1;
+			} else {
+				pdata->cpu_bufnum = START_CPU_BUFNUM_1;
+				pdata->eth_bufnum = START_ETH_BUFNUM_1;
+				pdata->bp_bufnum = START_BP_BUFNUM_1;
+				pdata->ring_num = START_RING_NUM_1;
+			}
 			break;
 		default:
 			break;
@@ -1478,6 +1485,7 @@ static const struct acpi_device_id xgene_enet_acpi_match[] = {
 	{ "APMC0D05", XGENE_ENET1},
 	{ "APMC0D30", XGENE_ENET1},
 	{ "APMC0D31", XGENE_ENET1},
+	{ "APMC0D3F", XGENE_ENET1},
 	{ "APMC0D26", XGENE_ENET2},
 	{ "APMC0D25", XGENE_ENET2},
 	{ }
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 50f92c3..ff89a5d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -56,6 +56,11 @@
 #define START_BP_BUFNUM_1	0x2A
 #define START_RING_NUM_1	264
 
+#define XG_START_CPU_BUFNUM_1	12
+#define XG_START_ETH_BUFNUM_1	2
+#define XG_START_BP_BUFNUM_1	0x22
+#define XG_START_RING_NUM_1	264
+
 #define X2_START_CPU_BUFNUM_0	0
 #define X2_START_ETH_BUFNUM_0	0
 #define X2_START_BP_BUFNUM_0	0x20
-- 
1.9.1
