From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] rtlwifi: Don't leak on error in _rtl_usb_receive()
Date: Wed, 26 Dec 2012 21:51:12 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1212262145220.23814@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: wlanfae <wlanfae@realtek.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:50391 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab2LZUvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 15:51:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We fail to release 'urb' if '_rtl_prep_rx_urb()' fails in
_rtl_usb_receive().
This patch should take care of the leak.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/rtlwifi/usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

 note: compile tested only.

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 29f0969..75c29e6 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -640,6 +640,7 @@ static int _rtl_usb_receive(struct ieee80211_hw *hw)
 			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
 				 "Failed to prep_rx_urb!!\n");
 			err = PTR_ERR(skb);
+			usb_free_urb(urb);
 			goto err_out;
 		}
 
-- 
1.7.1


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
