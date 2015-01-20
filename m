From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V2 for 3.19 1/7] rtlwifi: Remove logging statement that is no longer needed
Date: Tue, 20 Jan 2015 11:01:20 -0600
Message-ID: <1421773286-1039-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In commit e9538cf4f907 ("rtlwifi: Fix error when accessing unmapped memory
in skb"), a printk was included to indicate that the condition had been
reached. There is now enough evidence from other users that the fix is
working. That logging statement can now be removed.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [V3.18]
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
