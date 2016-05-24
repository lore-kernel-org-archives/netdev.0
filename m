From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 1/1] qed: Reset the enable flag for eth protocol.
Date: Tue, 24 May 2016 05:25:23 -0400
Message-ID: <1464081923-29368-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:65287 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754587AbcEXKIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 06:08:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the coding error in determining the enable flag for
the application/protocol. The enable flag should be set for all protocols
but the eth.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index a06d19a..21ec1c2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -222,7 +222,7 @@ qed_dcbx_process_tlv(struct qed_hwfn *p_hwfn,
 			 * indication, but we only got here if there was an
 			 * app tlv for the protocol, so dcbx must be enabled.
 			 */
-			enable = !!(type == DCBX_PROTOCOL_ETH);
+			enable = !(type == DCBX_PROTOCOL_ETH);
 
 			qed_dcbx_update_app_info(p_data, p_hwfn, enable, true,
 						 priority, tc, type);
-- 
1.8.3.1
