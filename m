From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V3.18] rtlwifi: Add check for get_btc_status callback
Date: Thu, 23 Oct 2014 11:27:09 -0500
Message-ID: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mike Galbraith <umgwanakikbuti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thadeu Cascardo <cascardo-s4Flwc3xefXVny7hquFfmQ@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Drivers that do not use the get_btc_status() callback may not define a
dummy routine. The caller needs to check before making the call.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Mike Galbraith <umgwanakikbuti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Thadeu Cascardo <cascardo-s4Flwc3xefXVny7hquFfmQ@public.gmane.org>
---

John,

This missing statement is causing kernel crashes for several of the drivers.
This patch should be applied ASAP.

Larry
---

 drivers/net/wireless/rtlwifi/pci.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 667aba8..25daa87 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1796,7 +1796,8 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 	rtl_pci_reset_trx_ring(hw);
 
 	rtlpci->driver_is_goingto_unload = false;
-	if (rtlpriv->cfg->ops->get_btc_status()) {
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status()) {
 		rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
 		rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
 	}
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
