From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/3] rtlwifi: rtl8723be: Fix sparse errors
Date: Wed,  5 Mar 2014 17:26:00 -0600
Message-ID: <1394061961-11682-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1394061961-11682-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394061961-11682-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sparse reports the following:

drivers/net/wireless/rtlwifi/rtl8723be/sw.c:374:14: sparse: duplicate const

drivers/net/wireless/rtlwifi/rtl8723be/hw.c:2214:30: sparse: cast to restricted __le32

Reported-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c | 3 +--
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index fc2af71..7e70c71 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -2210,8 +2210,7 @@ static void rtl8723be_update_hal_rate_mask(struct ieee80211_hw *hw,
 
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "ratr_bitmap :%x\n", ratr_bitmap);
-	*(u32 *)&rate_mask = EF4BYTE((ratr_bitmap & 0x0fffffff) |
-				     (ratr_index << 28));
+	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) | (ratr_index << 28);
 	rate_mask[0] = macid;
 	rate_mask[1] = _rtl8723be_mrate_idx_to_arfr_id(hw, ratr_index) |
 						       (shortgi ? 0x80 : 0x00);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index cc4ab3f..b4577eb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -370,7 +370,7 @@ MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
 MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is open)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
 
-static const SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
+static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
 
 static struct pci_driver rtl8723be_driver = {
 	.name = KBUILD_MODNAME,
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
