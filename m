From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 6/6] tg3: Remove unnecessary lock around
 tg3_flag_set
Date: Thu, 23 May 2013 14:11:27 -0700
Message-ID: <1369343487-6453-7-git-send-email-nsujir@broadcom.com>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1136 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758975Ab3EWVLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:42 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spinlock was needed when flags used to be a u32 and set/cleared
using bit operations. Now that we use the atomic set_bit, this lock
isn't needed.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bef3005..321bc3d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6366,9 +6366,7 @@ static void tg3_tx_recover(struct tg3 *tp)
 		    "Please report the problem to the driver maintainer "
 		    "and include system chipset information.\n");
 
-	spin_lock(&tp->lock);
 	tg3_flag_set(tp, TX_RECOVERY_PENDING);
-	spin_unlock(&tp->lock);
 }
 
 static inline u32 tg3_tx_avail(struct tg3_napi *tnapi)
-- 
1.8.1.4
