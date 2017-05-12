From: Xie Qirong <cheerx1994@gmail.com>
Subject: [PATCH] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Fri, 12 May 2017 15:35:55 +0800
Message-ID: <20170512073555.12333-1-cheerx1994@gmail.com>
Cc: linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Xie Qirong <cheerx1994@gmail.com>
To: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The combination of init_timer and setting up the data and function field
manually is equivalent to calling setup_timer(). This is an api
consolidation only and improves readability.

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
Signed-off-by: Xie Qirong <cheerx1994@gmail.com>
---

 setup_timer.cocci suggested the following improvement:
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
 setup_timer function for function on line 384.

 Patch was compile checked with: x86_64_defconfig + CONFIG_BRCMFMAC=y +
 CONFIG_BRCMFMAC_USB=y + CONFIG_BRCMFMAC_PCIE=y + CONFIG_BRCM_TRACING=y +
 CONFIG_BRCMDBG=y

 Kernel version: 4.11.0 (localversion-next is next-20170512)

 drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c
index 14a70d4b4e86..3559fb5b8fb0 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c
@@ -380,9 +380,7 @@ int brcmf_btcoex_attach(struct brcmf_cfg80211_info *cfg)
 	/* Set up timer for BT  */
 	btci->timer_on = false;
 	btci->timeout = BRCMF_BTCOEX_OPPR_WIN_TIME;
-	init_timer(&btci->timer);
-	btci->timer.data = (ulong)btci;
-	btci->timer.function = brcmf_btcoex_timerfunc;
+	setup_timer(&btci->timer, brcmf_btcoex_timerfunc, (ulong)btci);
 	btci->cfg = cfg;
 	btci->saved_regs_part1 = false;
 	btci->saved_regs_part2 = false;
-- 
2.12.2
