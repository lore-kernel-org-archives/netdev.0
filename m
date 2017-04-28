From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: [PATCH] drivers:net:ethernet:emulex:benet: Use time_before_eq for time comparison
Date: Fri, 28 Apr 2017 03:48:59 +0200
Message-ID: <1493344139-6678-1-git-send-email-karim.eshapa@gmail.com>
Cc: ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Karim Eshapa <karim.eshapa@gmail.com>,
        Karim Eshapa <kaim.eshapa@gmail.com>
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33684 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754879AbdD1BtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 21:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use time_before_eq for time comparison more safe and dealing
with timer wrapping to be future-proof.

Signed-off-by: Karim Eshapa <kaim.eshapa@gmail.com>
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
