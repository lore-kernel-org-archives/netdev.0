From: Daniel J Blueman <daniel@quora.org>
Subject: [PATCH] 4.9.13 brcmfmac: fix use-after-free on resume
Date: Mon, 6 Mar 2017 15:14:04 +0800
Message-ID: <CAMVG2stHA9qSUiRFBW=-4jhSMk-o7Frext+Qf9JK3Fo822XHhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Hante Meuleman <hante.meuleman@broadcom.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Pieter-Paul Giesberts <pieterpg@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:36308 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752688AbdCFHOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 02:14:05 -0500
Received: by mail-ua0-f196.google.com with SMTP id y16so15368297uay.3
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 23:14:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KASAN reported 'struct wireless_dev wdev' was read after being freed.
Fix by freeing after the access.

Signed-off-by: Daniel J Blueman <daniel@quora.org>

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
index de19c7c..aa0f470 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
@@ -2288,12 +2288,13 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy,
struct wireless_dev *wdev)
                else
                        err = 0;
        }
-       brcmf_remove_interface(vif->ifp, true);

-       brcmf_cfg80211_arm_vif_event(cfg, NULL);
        if (vif->wdev.iftype != NL80211_IFTYPE_P2P_DEVICE)
                p2p->bss_idx[P2PAPI_BSSCFG_CONNECTION].vif = NULL;

+       brcmf_remove_interface(vif->ifp, true);
+       brcmf_cfg80211_arm_vif_event(cfg, NULL);
+
        return err;
 }
-- 
Daniel J Blueman
