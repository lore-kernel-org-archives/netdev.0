From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH v2] ath6kl: drop unlikely behind WARN_ON()
Date: Mon,  5 Oct 2015 20:46:12 +0800
Message-ID: <61de1b17c432479ccded41edfb553e2d20ebf8ae.1444048783.git.geliangtang@163.com>
References: <87si5p4l09.fsf@kamboji.qca.qualcomm.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87si5p4l09.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARN_ON() already contain an unlikely compiler flag. Drop it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
Changes in v2:
 - change subject prefix to ath6kl.
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index a511ef3..fe38fc4 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -2217,7 +2217,7 @@ static int ath6kl_wow_suspend(struct ath6kl *ar, struct cfg80211_wowlan *wow)
 
 	/* enter / leave wow suspend on first vif always */
 	first_vif = ath6kl_vif_first(ar);
-	if (WARN_ON(unlikely(!first_vif)) ||
+	if (WARN_ON(!first_vif) ||
 	    !ath6kl_cfg80211_ready(first_vif))
 		return -EIO;
 
@@ -2297,7 +2297,7 @@ static int ath6kl_wow_resume(struct ath6kl *ar)
 	int ret;
 
 	vif = ath6kl_vif_first(ar);
-	if (WARN_ON(unlikely(!vif)) ||
+	if (WARN_ON(!vif) ||
 	    !ath6kl_cfg80211_ready(vif))
 		return -EIO;
 
-- 
2.5.0
