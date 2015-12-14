From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] ath9k_htc: fix handling return value of ath9k_hw_calibrate
Date: Mon, 14 Dec 2015 11:06:01 +0100
Message-ID: <1450087564-28441-4-git-send-email-a.hajda@samsung.com>
References: <1450087564-28441-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1450087564-28441-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function can return negative values in case of error.
Its result should be then tested for such case.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/wireless/ath/ath9k/htc_drv_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index a680a97..fe1fd1a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -834,7 +834,7 @@ void ath9k_htc_ani_work(struct work_struct *work)
 		if (longcal || shortcal)
 			common->ani.caldone =
 				ath9k_hw_calibrate(ah, ah->curchan,
-						   ah->rxchainmask, longcal);
+						ah->rxchainmask, longcal) > 0;
 
 		ath9k_htc_ps_restore(priv);
 	}
-- 
1.9.1
