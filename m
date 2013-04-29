From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] tg3: shows HW time stamping support only if ptp_capable is present
Date: Mon, 29 Apr 2013 14:08:07 -0300
Message-ID: <1367255287-2664-1-git-send-email-fbl@redhat.com>
Cc: Jiri Benc <jbenc@redhat.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab3D2RI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 13:08:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current tg3 shows hardware timestamping support for all devices
when that is true only for the hardware with PTP_CAPABLE flag
present.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ac83c87..ef0b8a6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5992,10 +5992,13 @@ static int tg3_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
 
 	info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
 				SOF_TIMESTAMPING_RX_SOFTWARE |
-				SOF_TIMESTAMPING_SOFTWARE    |
-				SOF_TIMESTAMPING_TX_HARDWARE |
-				SOF_TIMESTAMPING_RX_HARDWARE |
-				SOF_TIMESTAMPING_RAW_HARDWARE;
+				SOF_TIMESTAMPING_SOFTWARE;
+
+	if (tg3_flag(tp, PTP_CAPABLE)) {
+		info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
+					SOF_TIMESTAMPING_RX_HARDWARE |
+					SOF_TIMESTAMPING_RAW_HARDWARE;
+	}
 
 	if (tp->ptp_clock)
 		info->phc_index = ptp_clock_index(tp->ptp_clock);
-- 
1.8.1.4
