From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] b43: Increase number of RX DMA slots
Date: Sun, 17 Feb 2013 21:01:20 -0600
Message-ID: <1361156480-32566-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bastian Bittorf <bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bastian Bittorf reported that some of the silent freezes on a Linksys WRT54G
were due to overflow of the RX DMA ring buffer, which was created with 64
slots. That finding reminded me that I was seeing similar crashed on a netbook,
which also has a relatively slow processor. After increasing the number of
slots to 128, runs on the netbook that previously failed now worked; however,
I found that 109 slots had been used in one test. For that reason, the number
of slots is being increased to 256.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Bastian Bittorf <bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
---
 drivers/net/wireless/b43/dma.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/b43/dma.h
index 315b96e..9fdd198 100644
--- a/drivers/net/wireless/b43/dma.h
+++ b/drivers/net/wireless/b43/dma.h
@@ -169,7 +169,7 @@ struct b43_dmadesc_generic {
 
 /* DMA engine tuning knobs */
 #define B43_TXRING_SLOTS		256
-#define B43_RXRING_SLOTS		64
+#define B43_RXRING_SLOTS		256
 #define B43_DMA0_RX_FW598_BUFSIZE	(B43_DMA0_RX_FW598_FO + IEEE80211_MAX_FRAME_LEN)
 #define B43_DMA0_RX_FW351_BUFSIZE	(B43_DMA0_RX_FW351_FO + IEEE80211_MAX_FRAME_LEN)
 
-- 
1.8.1.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
