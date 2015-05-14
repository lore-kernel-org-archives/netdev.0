From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath9k_htc: drv_init: match wait_for_completion_timeout return type
Date: Thu, 14 May 2015 18:25:26 +0200
Message-ID: <1431620726-31680-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@venema.h4ckr.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:36545 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933104AbbENQdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 12:33:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return type of wait_for_completion_timeout is unsigned long not int.
As time_left is exclusively used for wait_for_completion_timeout here its
type is simply changed to unsigned long.

API conformance testing for completions with coccinelle spatches are being
used to locate API usage inconsistencies:
./drivers/net/wireless/ath/ath9k/htc_drv_init.c:81
	int return assigned to unsigned long

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH9K_HTC=m

Patch is against 4.1-rc3 (localversion-next is -next-20150514)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 7468562..6c001b8 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -74,7 +74,7 @@ static struct ath_ps_ops ath9k_htc_ps_ops = {
 
 static int ath9k_htc_wait_for_target(struct ath9k_htc_priv *priv)
 {
-	int time_left;
+	unsigned long time_left;
 
 	if (atomic_read(&priv->htc->tgt_ready) > 0) {
 		atomic_dec(&priv->htc->tgt_ready);
-- 
1.7.10.4
