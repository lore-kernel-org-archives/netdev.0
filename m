From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/6] rtlwifi: Fix warnings in usb.c
Date: Fri,  1 Feb 2013 10:40:23 -0600
Message-ID: <1359736827-30977-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359736827-30977-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Building this driver with "make W=3D1" results in the following 2 warni=
ngs:

drivers/net/wireless/rtlwifi/usb.c:829:21: warning: variable =E2=80=98u=
rb_list=E2=80=99 set but not used [-Wunused-but-set-variable]
drivers/net/wireless/rtlwifi/usb.c:828:23: warning: variable =E2=80=98s=
kb_list=E2=80=99 set but not used [-Wunused-but-set-variable]

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/usb.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/=
rtlwifi/usb.c
index 1535efd..d42bbe2 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -825,8 +825,6 @@ static void _rtl_usb_transmit(struct ieee80211_hw *=
hw, struct sk_buff *skb,
 	u32 ep_num;
 	struct urb *_urb =3D NULL;
 	struct sk_buff *_skb =3D NULL;
-	struct sk_buff_head *skb_list;
-	struct usb_anchor *urb_list;
=20
 	WARN_ON(NULL =3D=3D rtlusb->usb_tx_aggregate_hdl);
 	if (unlikely(IS_USB_STOP(rtlusb))) {
@@ -836,7 +834,6 @@ static void _rtl_usb_transmit(struct ieee80211_hw *=
hw, struct sk_buff *skb,
 		return;
 	}
 	ep_num =3D rtlusb->ep_map.ep_mapping[qnum];
-	skb_list =3D &rtlusb->tx_skb_queue[ep_num];
 	_skb =3D skb;
 	_urb =3D _rtl_usb_tx_urb_setup(hw, _skb, ep_num);
 	if (unlikely(!_urb)) {
@@ -844,7 +841,6 @@ static void _rtl_usb_transmit(struct ieee80211_hw *=
hw, struct sk_buff *skb,
 			 "Can't allocate urb. Drop skb!\n");
 		return;
 	}
-	urb_list =3D &rtlusb->tx_pending[ep_num];
 	_rtl_submit_tx_urb(hw, _urb);
 }
=20
--=20
1.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
