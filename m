From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 7/8] tg3: Remove unnecessary spinlock
Date: Fri, 20 Sep 2013 16:47:01 -0700
Message-ID: <1379720822-6500-8-git-send-email-nsujir@broadcom.com>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4805 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767Ab3ITXrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:14 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spinlock is not needed after conversion of tg3_flags from array to
set_bit().

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b0dd391..f3312cf 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12107,12 +12107,10 @@ static int tg3_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	device_set_wakeup_enable(dp, wol->wolopts & WAKE_MAGIC);
 
-	spin_lock_bh(&tp->lock);
 	if (device_may_wakeup(dp))
 		tg3_flag_set(tp, WOL_ENABLE);
 	else
 		tg3_flag_clear(tp, WOL_ENABLE);
-	spin_unlock_bh(&tp->lock);
 
 	return 0;
 }
-- 
1.8.1.4
