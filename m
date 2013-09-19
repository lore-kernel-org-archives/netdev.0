From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Align private space in rtl_priv struct
Date: Wed, 18 Sep 2013 21:21:35 -0500
Message-ID: <1379557295-18484-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private array at the end of the rtl_priv struct is not aligned.
On ARM architecture, this causes an alignment trap and is fixed by aligning
that array with __align(sizeof(void *)). That should properly align that
space according to the requirements of all architectures.

Reported-by: Jason Andrews <jasona@cadence.com>
Tested-by: Jason Andrews <jasona@cadence.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/wifi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index cc03e7c..7032587 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -2057,7 +2057,7 @@ struct rtl_priv {
 	   that it points to the data allocated
 	   beyond  this structure like:
 	   rtl_pci_priv or rtl_usb_priv */
-	u8 priv[0];
+	u8 priv[0] __aligned(sizeof(void *));
 };
 
 #define rtl_priv(hw)		(((struct rtl_priv *)(hw)->priv))
-- 
1.8.1.4
