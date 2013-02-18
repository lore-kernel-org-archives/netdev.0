From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 6/9] bnx2x: Prevent "Unknown MF" print in SF
 mode
Date: Mon, 18 Feb 2013 10:16:35 +0200
Message-ID: <1361175398-12888-7-git-send-email-yuvalmin@broadcom.com>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4589 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757459Ab3BRJV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:29 -0500
In-Reply-To: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

When using a chip operating in Single Function mode, when the chip is probed
the bnx2x would print a message warning of an unknown Multi Function mode.

This patch prevents said message.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f563fdc..2b7930c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11063,6 +11063,9 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 				} else
 					BNX2X_DEV_INFO("illegal OV for SD\n");
 				break;
+			case SHARED_FEAT_CFG_FORCE_SF_MODE_FORCED_SF:
+				bp->mf_config[vn] = 0;
+				break;
 			default:
 				/* Unknown configuration: reset mf_config */
 				bp->mf_config[vn] = 0;
-- 
1.7.9.GIT
