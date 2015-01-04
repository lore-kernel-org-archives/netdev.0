From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] brcm80211: brcmsmac: dma: Remove some unused functions
Date: Sun,  4 Jan 2015 01:47:49 +0100
Message-ID: <1420332469-5907-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@adurom.com>,
	Fabian Frederick <fabf@skynet.be>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes some functions that are not used anywhere:
dma_txflush() dma_txsuspended()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/brcm80211/brcmsmac/dma.c |   19 -------------------
 drivers/net/wireless/brcm80211/brcmsmac/dma.h |    2 --
 2 files changed, 21 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
index 796f5f9..bca233a 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
@@ -1192,16 +1192,6 @@ void dma_txresume(struct dma_pub *pub)
 	bcma_mask32(di->core, DMA64TXREGOFFS(di, control), ~D64_XC_SE);
 }
 
-bool dma_txsuspended(struct dma_pub *pub)
-{
-	struct dma_info *di = container_of(pub, struct dma_info, dma);
-
-	return (di->ntxd == 0) ||
-	       ((bcma_read32(di->core,
-			     DMA64TXREGOFFS(di, control)) & D64_XC_SE) ==
-		D64_XC_SE);
-}
-
 void dma_txreclaim(struct dma_pub *pub, enum txd_range range)
 {
 	struct dma_info *di = container_of(pub, struct dma_info, dma);
@@ -1425,15 +1415,6 @@ int dma_txfast(struct brcms_c_info *wlc, struct dma_pub *pub,
 	return -ENOSPC;
 }
 
-void dma_txflush(struct dma_pub *pub)
-{
-	struct dma_info *di = container_of(pub, struct dma_info, dma);
-	struct brcms_ampdu_session *session = &di->ampdu_session;
-
-	if (!skb_queue_empty(&session->skb_list))
-		ampdu_finalize(di);
-}
-
 int dma_txpending(struct dma_pub *pub)
 {
 	struct dma_info *di = container_of(pub, struct dma_info, dma);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.h b/drivers/net/wireless/brcm80211/brcmsmac/dma.h
index ff5b80b..210ec72 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.h
@@ -88,11 +88,9 @@ bool dma_txreset(struct dma_pub *pub);
 void dma_txinit(struct dma_pub *pub);
 int dma_txfast(struct brcms_c_info *wlc, struct dma_pub *pub,
 	       struct sk_buff *p0);
-void dma_txflush(struct dma_pub *pub);
 int dma_txpending(struct dma_pub *pub);
 void dma_kick_tx(struct dma_pub *pub);
 void dma_txsuspend(struct dma_pub *pub);
-bool dma_txsuspended(struct dma_pub *pub);
 void dma_txresume(struct dma_pub *pub);
 void dma_txreclaim(struct dma_pub *pub, enum txd_range range);
 void dma_rxreclaim(struct dma_pub *pub);
-- 
1.7.10.4
