From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V3.8 3/5] rtlwifi: rtl8192de: Fix warning for unchecked pci_map_single() call
Date: Wed, 26 Dec 2012 16:08:09 -0600
Message-ID: <1356559691-5048-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:58967 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab2LZWIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 17:08:52 -0500
In-Reply-To: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.8 implements checking of all DMA mapping calls and issues
a WARNING for the first it finds that is not checked.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index f9f3861..a0fbf28 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -587,6 +587,11 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 	buf_len = skb->len;
 	mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
 				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_92d));
 	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
 		firstseg = true;
@@ -740,6 +745,11 @@ void rtl92de_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)(skb->data);
 	__le16 fc = hdr->frame_control;
 
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
 	if (firstseg)
 		SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
-- 
1.7.10.4
