From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3.8 5/5 V2] rtlwifi: rtl8723ae: Fix warning for unchecked pci_map_single() call
Date: Thu, 27 Dec 2012 10:37:32 -0600
Message-ID: <1356626252-4058-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1356626252-4058-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:51669 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab2L0Qh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 11:37:56 -0500
In-Reply-To: <1356626252-4058-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.8 implements checking of all DMA mapping calls and issues
a WARNING for the first it finds that is not checked.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

No change in V2

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index 87331d8..7ddd517 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -387,6 +387,11 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 					    PCI_DMA_TODEVICE);
 	u8 bw_40 = 0;
 
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	if (mac->opmode == NL80211_IFTYPE_STATION) {
 		bw_40 = mac->bw_40;
 	} else if (mac->opmode == NL80211_IFTYPE_AP ||
@@ -542,6 +548,11 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 					    PCI_DMA_TODEVICE);
 	__le16 fc = hdr->frame_control;
 
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
 
 	if (firstseg)
-- 
1.7.10.4
