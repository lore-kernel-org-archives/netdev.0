From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH NEXT] rtl8187: Increase RX queue depth
Date: Tue, 29 Oct 2013 17:06:41 -0500
Message-ID: <1383084401-4593-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Under heavy load, the relatively small number of RX queue entries are
completely filled. With an increase from 16 to 32 entries, this condition
rarely happens.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtl818x/rtl8187/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index 9a6edb0..ec9aa5b 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -416,7 +416,7 @@ static int rtl8187_init_urbs(struct ieee80211_hw *dev)
 	struct rtl8187_rx_info *info;
 	int ret = 0;
 
-	while (skb_queue_len(&priv->rx_queue) < 16) {
+	while (skb_queue_len(&priv->rx_queue) < 32) {
 		skb = __dev_alloc_skb(RTL8187_MAX_RX, GFP_KERNEL);
 		if (!skb) {
 			ret = -ENOMEM;
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
