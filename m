From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] tg3: fix to append hardware time stamping flags
Date: Tue, 30 Apr 2013 11:09:37 -0300
Message-ID: <1367330977-6470-1-git-send-email-fbl@redhat.com>
Cc: Jiri Benc <jbenc@redhat.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759128Ab3D3OJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 10:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit f233a976ad15c3b8c54c0157f3c41d23f7514279 fixing the
hardware time stamping support didn't append hardware flags.
This patch fixes it.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ef0b8a6..728d42a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5995,7 +5995,7 @@ static int tg3_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
 				SOF_TIMESTAMPING_SOFTWARE;
 
 	if (tg3_flag(tp, PTP_CAPABLE)) {
-		info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
+		info->so_timestamping |= SOF_TIMESTAMPING_TX_HARDWARE |
 					SOF_TIMESTAMPING_RX_HARDWARE |
 					SOF_TIMESTAMPING_RAW_HARDWARE;
 	}
-- 
1.8.1.4
