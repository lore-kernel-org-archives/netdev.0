From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] cfg80211: Fix a memory leak in error handling path in 'brcmf_cfg80211_attach'
Date: Tue, 20 Jun 2017 08:22:05 +0200
Message-ID: <20170620062205.16078-1-christophe.jaillet@wanadoo.fr>
Cc: linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, kvalo@codeaurora.org,
        rafal@milecki.pl, pieter-paul.giesberts@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If 'wiphy_new()' fails, we leak 'ops'. Add a new label in the error
handling path to free it in such a case.

Fixes: 5c22fb85102a7 ("brcmfmac: add wowl gtk rekeying offload support")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 2443c71a202f..032d823c53c2 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -6861,7 +6861,7 @@ struct brcmf_cfg80211_info *brcmf_cfg80211_attach(struct brcmf_pub *drvr,
 	wiphy = wiphy_new(ops, sizeof(struct brcmf_cfg80211_info));
 	if (!wiphy) {
 		brcmf_err("Could not allocate wiphy device\n");
-		return NULL;
+		goto ops_out;
 	}
 	memcpy(wiphy->perm_addr, drvr->mac, ETH_ALEN);
 	set_wiphy_dev(wiphy, busdev);
@@ -7012,6 +7012,7 @@ struct brcmf_cfg80211_info *brcmf_cfg80211_attach(struct brcmf_pub *drvr,
 	ifp->vif = NULL;
 wiphy_out:
 	brcmf_free_wiphy(wiphy);
+ops_out:
 	kfree(ops);
 	return NULL;
 }
-- 
2.11.0
