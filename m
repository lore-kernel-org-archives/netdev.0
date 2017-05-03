From: Xie Qirong <cheerx1994-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Wed,  3 May 2017 15:35:55 +0800
Message-ID: <20170503073555.3922-1-cheerx1994@gmail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Piotr Haber <phaber-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Xie Qirong <cheerx1994-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Xie Qirong <cheerx1994-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 setup_timer.cocci suggested the following improvement:
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
 setup_timer function for function on line 384.

 Patch was compile checked with: x86_64_defconfig + CONFIG_BRCMFMAC=y +
 CONFIG_BRCMFMAC_USB=y + CONFIG_BRCMFMAC_PCIE=y + CONFIG_BRCM_TRACING=y +
 CONFIG_BRCMDBG=y

 Kernel version: next-20170502 (localversion-next is next-20170502)

 drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c
index 14a70d4..3559fb5 100644
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
2.9.3
