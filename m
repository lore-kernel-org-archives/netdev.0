From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath9k: match wait_for_completion_timeout return type
Date: Thu, 14 May 2015 18:56:16 +0200
Message-ID: <1431622576-9183-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@venema.h4ckr.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:36715 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932698AbbENREd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 13:04:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return type of wait_for_completion_timeout is unsigned long not int.
As time_left is exclusively used for wait_for_completion_timeout here its
type is simply changed to unsigned long.

API conformance testing for completions with coccinelle spatches are being
used to locate API usage inconsistencies:
./drivers/net/wireless/ath/ath9k/link.c:197
        int return assigned to unsigned long

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,

Patch is against 4.1-rc3 (localversion-next is -next-20150514)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---
 drivers/net/wireless/ath/ath9k/link.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/ath/ath9k/link.c
index 90631d7..5ad0fee 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -172,7 +172,7 @@ static bool ath_paprd_send_frame(struct ath_softc *sc, struct sk_buff *skb, int
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath_tx_control txctl;
-	int time_left;
+	unsigned long time_left;
 
 	memset(&txctl, 0, sizeof(txctl));
 	txctl.txq = sc->tx.txq_map[IEEE80211_AC_BE];
-- 
1.7.10.4
