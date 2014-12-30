From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH 3/4] ath10k: fixup wait_for_completion_timeout return handling
Date: Tue, 30 Dec 2014 07:20:45 -0500
Message-ID: <1419942046-17985-4-git-send-email-der.herr@hofr.at>
References: <1419942046-17985-1-git-send-email-der.herr@hofr.at>
Cc: Michal Kazior <michal.kazior@tieto.com>,
	Ben Greear <greearb@candelatech.com>,
	Chun-Yeow Yeoh <yeohchunyeow@gmail.com>,
	Yanbo Li <yanbol@qti.qualcomm.com>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <der.herr@hofr.at>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419942046-17985-1-git-send-email-der.herr@hofr.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wait_for_completion_timeout does not return negative values so
"ret" handling here should check for timeout only.

patch was only compile tested for x86_64_defconfig + CONFIG_ATH10K=m

patch is against linux-next 3.19.0-rc1 -next-20141226

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---
 drivers/net/wireless/ath/ath10k/htc.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/htc.c b/drivers/net/wireless/ath/ath10k/htc.c
index f1946a6..2fd9e18 100644
--- a/drivers/net/wireless/ath/ath10k/htc.c
+++ b/drivers/net/wireless/ath/ath10k/htc.c
@@ -703,11 +703,9 @@ int ath10k_htc_connect_service(struct ath10k_htc *htc,
 	/* wait for response */
 	status = wait_for_completion_timeout(&htc->ctl_resp,
 					     ATH10K_HTC_CONN_SVC_TIMEOUT_HZ);
-	if (status <= 0) {
-		if (status == 0)
-			status = -ETIMEDOUT;
+	if (status == 0) {
 		ath10k_err(ar, "Service connect timeout: %d\n", status);
-		return status;
+		return -ETIMEDOUT;
 	}
 
 	/* we controlled the buffer creation, it's aligned */
-- 
1.7.10.4
