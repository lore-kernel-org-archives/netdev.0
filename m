From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] wcn36xx: Fix error handling
Date: Sun, 19 Feb 2017 18:47:51 +0100
Message-ID: <20170219174751.18966-1-christophe.jaillet@wanadoo.fr>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: k.eugene.e@gmail.com, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.smtpout.orange.fr ([80.12.242.133]:51389 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdBSRu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 12:50:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorder 'out_free_dxe_pool' and 'out_free_dxe_ctl' error handling labels
in order to match the way resources have been allocated.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index cee4f655bf36..6436235bc265 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -337,10 +337,10 @@ static int wcn36xx_start(struct ieee80211_hw *hw)
 	wcn36xx_smd_stop(wcn);
 out_free_smd_buf:
 	kfree(wcn->hal_buf);
-out_free_dxe_pool:
-	wcn36xx_dxe_free_mem_pools(wcn);
 out_free_dxe_ctl:
 	wcn36xx_dxe_free_ctl_blks(wcn);
+out_free_dxe_pool:
+	wcn36xx_dxe_free_mem_pools(wcn);
 out_smd_close:
 	wcn36xx_smd_close(wcn);
 out_err:
-- 
2.9.3
