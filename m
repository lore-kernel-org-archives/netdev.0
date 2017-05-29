From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 01/10] qed: Add missing static/local dcbx info
Date: Mon, 29 May 2017 09:53:05 +0300
Message-ID: <1496040794-6163-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1496040794-6163-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0066.outbound.protection.outlook.com ([104.47.32.66]:41824
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750893AbdE2Gxe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 02:53:34 -0400
In-Reply-To: <1496040794-6163-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Some getters are not getting filled with the correct information
regarding local DCBx.

Fixes: 49632b5822ea ("qed: Add support for static dcbx.")
Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index b83fe1d..efe309e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1460,7 +1460,7 @@ static u8 qed_dcbnl_getcap(struct qed_dev *cdev, int capid, u8 *cap)
 		break;
 	case DCB_CAP_ATTR_DCBX:
 		*cap = (DCB_CAP_DCBX_LLD_MANAGED | DCB_CAP_DCBX_VER_CEE |
-			DCB_CAP_DCBX_VER_IEEE);
+			DCB_CAP_DCBX_VER_IEEE | DCB_CAP_DCBX_STATIC);
 		break;
 	default:
 		*cap = false;
@@ -1534,6 +1534,8 @@ static u8 qed_dcbnl_getdcbx(struct qed_dev *cdev)
 		mode |= DCB_CAP_DCBX_VER_IEEE;
 	if (dcbx_info->operational.cee)
 		mode |= DCB_CAP_DCBX_VER_CEE;
+	if (dcbx_info->operational.local)
+		mode |= DCB_CAP_DCBX_STATIC;
 
 	DP_VERBOSE(hwfn, QED_MSG_DCB, "dcb mode = %d\n", mode);
 	kfree(dcbx_info);
-- 
1.9.3
