From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 06/10] net: wireless: ath: simplify return flow for carl9170_regwrite_result()
Date: Wed, 28 Oct 2015 00:32:41 +0530
Message-ID: <1445972565-14963-6-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the carl9170/phy.c file that fixes warning reported by
coccicheck :

 WARNING: end returns can be simplified

I have removed unneccessary variable declaration and simply return flow
for carl9170_regwrite_result()

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ath/carl9170/phy.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/phy.c b/drivers/net/wireless/ath/carl9170/phy.c
index dca6df1..f3b5434 100644
--- a/drivers/net/wireless/ath/carl9170/phy.c
+++ b/drivers/net/wireless/ath/carl9170/phy.c
@@ -966,7 +966,6 @@ static const struct carl9170_phy_freq_entry carl9170_phy_freq_params[] = {
 static int carl9170_init_rf_bank4_pwr(struct ar9170 *ar, bool band5ghz,
 				      u32 freq, enum carl9170_bw bw)
 {
-	int err;
 	u32 d0, d1, td0, td1, fd0, fd1;
 	u8 chansel;
 	u8 refsel0 = 1, refsel1 = 0;
@@ -1024,11 +1023,7 @@ static int carl9170_init_rf_bank4_pwr(struct ar9170 *ar, bool band5ghz,
 	carl9170_regwrite(0x1c58e8, fd1);
 
 	carl9170_regwrite_finish();
-	err = carl9170_regwrite_result();
-	if (err)
-		return err;
-
-	return 0;
+	return carl9170_regwrite_result();
 }
 
 static const struct carl9170_phy_freq_params *
-- 
2.5.3
