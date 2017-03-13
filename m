From: Alban <albeu@free.fr>
Subject: [PATCH 7/7] ath9k: hw: Reset the device with the external reset before init
Date: Mon, 13 Mar 2017 22:05:15 +0100
Message-ID: <1489439116-4233-7-git-send-email-albeu@free.fr>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the SoC platform the board code often manually reset the device
before registering it. To allow the same to happen on DT platforms
let the driver call the reset before init.

Signed-off-by: Alban <albeu@free.fr>
---
 drivers/net/wireless/ath/ath9k/hw.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index efc0435..dfb13bc 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -576,6 +576,13 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 	struct ath_common *common = ath9k_hw_common(ah);
 	int r = 0;
 
+	/* Reset the device before using it */
+	r = ath9k_hw_external_reset(ah);
+	if (r) {
+		ath_err(common, "Failed to reset chip\n");
+		return r;
+	}
+
 	ath9k_hw_read_revisions(ah);
 
 	switch (ah->hw_version.macVersion) {
-- 
2.7.4
