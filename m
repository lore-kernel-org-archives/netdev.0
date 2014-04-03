From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: [PATCH] rtlwifi: btcoexist: remove undefined Kconfig macros
Date: Thu, 03 Apr 2014 10:12:51 +0200
Message-ID: <1396512771.31985.5.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There are references to four undefined Kconfig macros in the code.
Commit 8542373dccd2 ("Staging: rtl8812ae: remove undefined Kconfig
macros") removed identical references from that staging driver, but
they resurfaced in rtlwifi. Remove these again as the checks for them
still will always evaluate to false.

Signed-off-by: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
---
Tested by grepping the tree only.

A follow up could now remove both "enum btc_chip_interface" and
"chip_interface", couldn't it?

 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index b6722de6..33da3df 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -625,17 +625,7 @@ bool exhalbtc_initlize_variables(struct rtl_priv *adapter)
 	else
 		btcoexist->binded = true;
 
-#if (defined(CONFIG_PCI_HCI))
-	btcoexist->chip_interface = BTC_INTF_PCI;
-#elif (defined(CONFIG_USB_HCI))
-	btcoexist->chip_interface = BTC_INTF_USB;
-#elif (defined(CONFIG_SDIO_HCI))
-	btcoexist->chip_interface = BTC_INTF_SDIO;
-#elif (defined(CONFIG_GSPI_HCI))
-	btcoexist->chip_interface = BTC_INTF_GSPI;
-#else
 	btcoexist->chip_interface = BTC_INTF_UNKNOWN;
-#endif
 
 	if (NULL == btcoexist->adapter)
 		btcoexist->adapter = adapter;
-- 
1.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
