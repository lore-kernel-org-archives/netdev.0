From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: [PATCH] benet: Use time_before_eq for time comparison
Date: Mon,  1 May 2017 15:58:08 +0200
Message-ID: <1493647088-4394-1-git-send-email-karim.eshapa@gmail.com>
References: <1493344139-6678-1-git-send-email-karim.eshapa@gmail.com>
Cc: ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Karim Eshapa <karim.eshapa@gmail.com>
To: sathya.perla@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493344139-6678-1-git-send-email-karim.eshapa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use time_before_eq for time comparison more safe and dealing
with timer wrapping to be future-proof.

Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6be3b9a..56d2368 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5217,15 +5217,15 @@ static bool be_err_is_recoverable(struct be_adapter *adapter)
 	dev_err(&adapter->pdev->dev, "Recoverable HW error code: 0x%x\n",
 		ue_err_code);
 
-	if (jiffies - err_rec->probe_time <= initial_idle_time) {
+	if (time_before_eq(jiffies - err_rec->probe_time, initial_idle_time)) {
 		dev_err(&adapter->pdev->dev,
 			"Cannot recover within %lu sec from driver load\n",
 			jiffies_to_msecs(initial_idle_time) / MSEC_PER_SEC);
 		return false;
 	}
 
-	if (err_rec->last_recovery_time &&
-	    (jiffies - err_rec->last_recovery_time <= recovery_interval)) {
+	if (err_rec->last_recovery_time && time_before_eq(
+		jiffies - err_rec->last_recovery_time, recovery_interval)) {
 		dev_err(&adapter->pdev->dev,
 			"Cannot recover within %lu sec from last recovery\n",
 			jiffies_to_msecs(recovery_interval) / MSEC_PER_SEC);
-- 
2.7.4
