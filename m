From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 5/8 V4] rtlwifi: Fix smatch warning in pci.c
Date: Wed, 25 Sep 2013 12:57:46 -0500
Message-ID: <1380131869-19185-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380131869-19185-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Smatch reports the following:
  CHECK   drivers/net/wireless/rtlwifi/pci.c
drivers/net/wireless/rtlwifi/pci.c:739 _rtl_pci_rx_interrupt() warn: assigning (-98) to unsigned variable 'stats.noise'

The variable 'stats.noise' is not used. That initializer is removed.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/pci.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 703f839..6295ed2 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -736,7 +736,6 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 
 	struct rtl_stats stats = {
 		.signal = 0,
-		.noise = -98,
 		.rate = 0,
 	};
 	int index = rtlpci->rx_ring[rx_queue_idx].idx;
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
