From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 04/12] cxgb4: distinguish between 1-lane KR/KX and 4-lane KR/KX/KX4 ports
Date: Tue, 14 Dec 2010 23:36:47 -0800
Message-ID: <1292398615-26527-5-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
 <1292398615-26527-4-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2391 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICK004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:18 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7aup6026589
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:56 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7au1o026588
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:56 -0800
In-Reply-To: <1292398615-26527-4-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And fix the supported flags ethtool reports for the two cases.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    9 +++++++--
 drivers/net/cxgb4/t4fw_api.h   |    1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 3012a8a..3f33d51 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1375,7 +1375,12 @@ static unsigned int from_fw_linkcaps(unsigned int type, unsigned int caps)
 	} else if (type == FW_PORT_TYPE_KR)
 		v |= SUPPORTED_Backplane | SUPPORTED_10000baseKR_Full;
 	else if (type == FW_PORT_TYPE_BP_AP)
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC;
+		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
+		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full;
+	else if (type == FW_PORT_TYPE_BP4_AP)
+		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
+		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full |
+		     SUPPORTED_10000baseKX4_Full;
 	else if (type == FW_PORT_TYPE_FIBER_XFI ||
 		 type == FW_PORT_TYPE_FIBER_XAUI || type == FW_PORT_TYPE_SFP)
 		v |= SUPPORTED_FIBRE;
@@ -3489,7 +3494,7 @@ static void __devinit print_port_info(struct adapter *adap)
 {
 	static const char *base[] = {
 		"R XFI", "R XAUI", "T SGMII", "T XFI", "T XAUI", "KX4", "CX4",
-		"KX", "KR", "KR SFP+", "KR FEC"
+		"KX", "KR", "R SFP+", "KR/KX", "KR/KX/KX4"
 	};
 
 	int i;
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
index 940584a..edcfd7e 100644
--- a/drivers/net/cxgb4/t4fw_api.h
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -1239,6 +1239,7 @@ enum fw_port_type {
 	FW_PORT_TYPE_KR,
 	FW_PORT_TYPE_SFP,
 	FW_PORT_TYPE_BP_AP,
+	FW_PORT_TYPE_BP4_AP,
 
 	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_MASK
 };
-- 
1.5.4

