From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Fix decoding QSA module for ethtool get settings
Date: Wed, 17 Dec 2014 17:36:00 +0530
Message-ID: <1418817960-17277-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17127 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751033AbaLQMAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 07:00:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QSA module was getting decoded as QSFP module in ethtool get settings, this
patch fixes it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 28d0415..c132d90 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2376,7 +2376,7 @@ const char *t4_get_port_type_description(enum fw_port_type port_type)
 		"KR/KX",
 		"KR/KX/KX4",
 		"R QSFP_10G",
-		"",
+		"R QSA",
 		"R QSFP",
 		"R BP40_BA",
 	};
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 291b6f2..7c0aec8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -2470,8 +2470,8 @@ enum fw_port_type {
 	FW_PORT_TYPE_BP_AP,
 	FW_PORT_TYPE_BP4_AP,
 	FW_PORT_TYPE_QSFP_10G,
-	FW_PORT_TYPE_QSFP,
 	FW_PORT_TYPE_QSA,
+	FW_PORT_TYPE_QSFP,
 	FW_PORT_TYPE_BP40_BA,
 
 	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_M
-- 
1.7.1
