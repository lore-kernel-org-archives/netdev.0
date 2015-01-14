From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 3.19 1/3] rtlwifi: Remove logging statement that is no longer needed
Date: Wed, 14 Jan 2015 11:37:14 -0600
Message-ID: <1421257036-5382-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:51412 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbANRhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:37:34 -0500
In-Reply-To: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit e9538cf4f907 ("rtlwifi: Fix error when accessing unmapped memory
in skb"), a printk was included to indicate that the condition had been
reached. There is now enough evidence from other users that the fix is
working. That logging statement can now be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/pci.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index c70efb9..e25faac 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -816,11 +816,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 
 		/* get a new skb - if fail, old one will be reused */
 		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
-		if (unlikely(!new_skb)) {
-			pr_err("Allocation of new skb failed in %s\n",
-			       __func__);
+		if (unlikely(!new_skb))
 			goto no_new;
-		}
 		if (rtlpriv->use_new_trx_flow) {
 			buffer_desc =
 			  &rtlpci->rx_ring[rxring_idx].buffer_desc
-- 
2.1.2
