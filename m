From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: replace WARNING on timeout with a simple error message
Date: Tue, 27 Sep 2016 12:12:24 +0200
Message-ID: <20160927101224.3534-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

Even with timeout increased to 950 ms we get WARNINGs from time to time.
It mostly happens on A-MPDU stalls (e.g. when station goes out of
range). It may take up to 5-10 secods for the firmware to recover and
for that time it doesn't process packets.

It's still useful to have a message on time out as it may indicate some
firmware problem and incorrect key update. Raising a WARNING however
wasn't really that necessary, it doesn't point to any driver bug anymore
and backtrace wasn't much useful.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 6d046ba..9e6f60a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -1161,7 +1161,8 @@ int brcmf_netdev_wait_pend8021x(struct brcmf_if *ifp)
 				 !brcmf_get_pend_8021x_cnt(ifp),
 				 MAX_WAIT_FOR_8021X_TX);
 
-	WARN_ON(!err);
+	if (!err)
+		brcmf_err("Timed out waiting for no pending 802.1x packets\n");
 
 	return !err;
 }
-- 
2.9.3
