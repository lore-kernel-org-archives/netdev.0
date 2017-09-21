From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 04/64] drivers: net: brcm80211: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:25 +0530
Message-ID: <1506013525-29291-5-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index aaed4ab..ab3f223 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -3260,9 +3260,8 @@ static void brcmf_init_escan(struct brcmf_cfg80211_info *cfg)
 			    brcmf_cfg80211_escan_handler);
 	cfg->escan_info.escan_state = WL_ESCAN_STATE_IDLE;
 	/* Init scan_timeout timer */
-	init_timer(&cfg->escan_timeout);
-	cfg->escan_timeout.data = (unsigned long) cfg;
-	cfg->escan_timeout.function = brcmf_escan_timeout;
+	setup_timer(&cfg->escan_timeout, brcmf_escan_timeout,
+		    (unsigned long)cfg);
 	INIT_WORK(&cfg->escan_timeout_work,
 		  brcmf_cfg80211_escan_timeout_worker);
 }
-- 
2.7.4
