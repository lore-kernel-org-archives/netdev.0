From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 16/16] net: wireless: realtek: rtlwifi: usb: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:13:08 +0200
Message-ID: <1470949988-25705-4-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
 <1470949988-25705-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949988-25705-1-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
---
 drivers/net/wireless/realtek/rtlwifi/usb.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
index 41617b7b082260..32aa5c1d070a07 100644
--- a/drivers/net/wireless/realtek/rtlwifi/usb.c
+++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
@@ -739,11 +739,8 @@ static int _rtl_usb_receive(struct ieee80211_hw *hw)
 	for (i = 0; i < rtlusb->rx_urb_num; i++) {
 		err = -ENOMEM;
 		urb = usb_alloc_urb(0, GFP_KERNEL);
-		if (!urb) {
-			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-				 "Failed to alloc URB!!\n");
+		if (!urb)
 			goto err_out;
-		}
 
 		err = _rtl_prep_rx_urb(hw, rtlusb, urb, GFP_KERNEL);
 		if (err < 0) {
@@ -907,15 +904,12 @@ static void _rtl_tx_complete(struct urb *urb)
 static struct urb *_rtl_usb_tx_urb_setup(struct ieee80211_hw *hw,
 				struct sk_buff *skb, u32 ep_num)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_usb *rtlusb = rtl_usbdev(rtl_usbpriv(hw));
 	struct urb *_urb;
 
 	WARN_ON(NULL == skb);
 	_urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!_urb) {
-		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 "Can't allocate URB for bulk out!\n");
 		kfree_skb(skb);
 		return NULL;
 	}
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
