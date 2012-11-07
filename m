From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 1/2] bnx2x: HSI change for 'update' ramrod
Date: Wed, 7 Nov 2012 12:45:47 +0200
Message-ID: <1352285148-21784-2-git-send-email-meravs@broadcom.com>
References: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	"Merav Sicron" <meravs@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3300 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053Ab2KGHf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 02:35:56 -0500
In-Reply-To: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the driver-FW HSI to support changes to the 'update' ramrod
(FW supports this change since 7.8.2). This ramrod is sent when the cnic module
registers bnx2x, to enable changing the nic_mode configuration in HW at
run-time.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 1870492..7eaa74b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -4845,9 +4845,17 @@ struct vif_list_event_data {
 	__le32 reserved2;
 };

-/*
- * union for all event ring message types
- */
+/* function update event data */
+struct function_update_event_data {
+	u8 echo;
+	u8 reserved;
+	__le16 reserved0;
+	__le32 reserved1;
+	__le32 reserved2;
+};
+
+
+/* union for all event ring message types */
 union event_data {
 	struct vf_pf_event_data vf_pf_event;
 	struct eth_event_data eth_event;
@@ -4855,6 +4863,7 @@ union event_data {
 	struct vf_flr_event_data vf_flr_event;
 	struct malicious_vf_event_data malicious_vf_event;
 	struct vif_list_event_data vif_list_event;
+	struct function_update_event_data function_update_event;
 };


@@ -4984,8 +4993,10 @@ struct function_update_data {
 	u8 allowed_priorities;
 	u8 network_cos_mode;
 	u8 lb_mode_en;
-	u8 reserved0;
-	__le32 reserved1;
+	u8 tx_switch_suspend_change_flg;
+	u8 tx_switch_suspend;
+	u8 echo;
+	__le16 reserved1;
 };


--
1.7.10
