From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 2/3] qed: Set selection-field while configuring the app entry in ieee mode.
Date: Mon, 29 Aug 2016 08:29:53 -0400
Message-ID: <1472473794-11933-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        <sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34342 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932956AbcH2NNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:13:44 -0400
In-Reply-To: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Management firmware requires the selection-field (SF) to be set for
configuring the application/protocol entry in IEEE mode. Without this
setting, the app entry will be configured incorrectly in MFW.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 7ad1667..192a886 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1063,23 +1063,31 @@ qed_dcbx_set_app_data(struct qed_hwfn *p_hwfn,
 	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
 		entry = &p_app->app_pri_tbl[i].entry;
 		if (ieee) {
-			*entry &= ~DCBX_APP_SF_IEEE_MASK;
+			*entry &= ~(DCBX_APP_SF_IEEE_MASK | DCBX_APP_SF_MASK);
 			switch (p_params->app_entry[i].sf_ieee) {
 			case QED_DCBX_SF_IEEE_ETHTYPE:
 				*entry |= ((u32)DCBX_APP_SF_IEEE_ETHTYPE <<
 					   DCBX_APP_SF_IEEE_SHIFT);
+				*entry |= ((u32)DCBX_APP_SF_ETHTYPE <<
+					   DCBX_APP_SF_SHIFT);
 				break;
 			case QED_DCBX_SF_IEEE_TCP_PORT:
 				*entry |= ((u32)DCBX_APP_SF_IEEE_TCP_PORT <<
 					   DCBX_APP_SF_IEEE_SHIFT);
+				*entry |= ((u32)DCBX_APP_SF_PORT <<
+					   DCBX_APP_SF_SHIFT);
 				break;
 			case QED_DCBX_SF_IEEE_UDP_PORT:
 				*entry |= ((u32)DCBX_APP_SF_IEEE_UDP_PORT <<
 					   DCBX_APP_SF_IEEE_SHIFT);
+				*entry |= ((u32)DCBX_APP_SF_PORT <<
+					   DCBX_APP_SF_SHIFT);
 				break;
 			case QED_DCBX_SF_IEEE_TCP_UDP_PORT:
 				*entry |= ((u32)DCBX_APP_SF_IEEE_TCP_UDP_PORT <<
 					   DCBX_APP_SF_IEEE_SHIFT);
+				*entry |= ((u32)DCBX_APP_SF_PORT <<
+					   DCBX_APP_SF_SHIFT);
 				break;
 			}
 		} else {
-- 
1.8.3.1
