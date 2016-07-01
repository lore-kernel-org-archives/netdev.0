From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/11] bnxt_en: Request firmware reset after successful firwmare update
Date: Fri,  1 Jul 2016 18:46:23 -0400
Message-ID: <1467413189-29566-6-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34172 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbcGAWqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:47 -0400
Received: by mail-pa0-f45.google.com with SMTP id bz2so42228902pad.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:47 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <rob.swindell@broadcom.com>

Upon successful mgmt processor firmware update, request a self
reset upon next PCIe reset (e.g. system reboot).

Signed-off-by: Rob Swindell <rob.swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 3328aa5..12a5141 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1059,6 +1059,8 @@ static int bnxt_firmware_reset(struct net_device *dev,
 	case BNX_DIR_TYPE_APE_FW:
 	case BNX_DIR_TYPE_APE_PATCH:
 		req.embedded_proc_type = FW_RESET_REQ_EMBEDDED_PROC_TYPE_MGMT;
+		/* Self-reset APE upon next PCIe reset: */
+		req.selfrst_status = FW_RESET_REQ_SELFRST_STATUS_SELFRSTPCIERST;
 		break;
 	case BNX_DIR_TYPE_KONG_FW:
 	case BNX_DIR_TYPE_KONG_PATCH:
-- 
1.8.3.1
