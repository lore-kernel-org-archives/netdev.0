From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 08/10] bnx2x: use BNX2X_Q_FLG_TPA_IPV6 for TPA queue
 configuration
Date: Tue, 19 Jul 2011 14:44:11 +0300
Message-ID: <1311075851.30287.10.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1572 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335Ab1GSLum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    4 +++-
 drivers/net/bnx2x/bnx2x_sp.c   |    2 +-
 drivers/net/bnx2x/bnx2x_sp.h   |    1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index b8f8793..7a89182 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2699,8 +2699,10 @@ static inline unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
 	if (IS_FCOE_FP(fp))
 		__set_bit(BNX2X_Q_FLG_FCOE, &flags);
 
-	if (!fp->disable_tpa)
+	if (!fp->disable_tpa) {
 		__set_bit(BNX2X_Q_FLG_TPA, &flags);
+		__set_bit(BNX2X_Q_FLG_TPA_IPV6, &flags);
+	}
 
 	if (leading) {
 		__set_bit(BNX2X_Q_FLG_LEADING_RSS, &flags);
diff --git a/drivers/net/bnx2x/bnx2x_sp.c b/drivers/net/bnx2x/bnx2x_sp.c
index 6306ff5..5a213e4 100644
--- a/drivers/net/bnx2x/bnx2x_sp.c
+++ b/drivers/net/bnx2x/bnx2x_sp.c
@@ -4240,7 +4240,7 @@ static void bnx2x_q_fill_setup_data_e2(struct bnx2x *bp,
 	/* Rx data */
 
 	/* IPv6 TPA supported for E2 and above only */
-	data->rx.tpa_en |= test_bit(BNX2X_Q_FLG_TPA, &params->flags) *
+	data->rx.tpa_en |= test_bit(BNX2X_Q_FLG_TPA_IPV6, &params->flags) *
 				CLIENT_INIT_RX_DATA_TPA_EN_IPV6;
 }
 
diff --git a/drivers/net/bnx2x/bnx2x_sp.h b/drivers/net/bnx2x/bnx2x_sp.h
index 73400dd..9a517c2 100644
--- a/drivers/net/bnx2x/bnx2x_sp.h
+++ b/drivers/net/bnx2x/bnx2x_sp.h
@@ -749,6 +749,7 @@ enum bnx2x_queue_cmd {
 /* queue SETUP + INIT flags */
 enum {
 	BNX2X_Q_FLG_TPA,
+	BNX2X_Q_FLG_TPA_IPV6,
 	BNX2X_Q_FLG_STATS,
 	BNX2X_Q_FLG_ZERO_STATS,
 	BNX2X_Q_FLG_ACTIVE,
-- 
1.7.2.2




