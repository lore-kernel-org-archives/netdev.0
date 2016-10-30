From: John Heenan <john@zgus.com>
Subject: [PATCH 1/2] rtl8xxxu: Fix for authentication failure
Date: Sun, 30 Oct 2016 20:20:46 +1000
Message-ID: <20161030102046.GA5784@cube>
References: <cover.1477769750.git.john@zgus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1477769750.git.john@zgus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fix enables the same sequence of init behaviour as the alternative
working driver for the wireless rtl8723bu IC at
https://github.com/lwfinger/rtl8723bu

For exampe rtl8xxxu_init_device is now called each time
userspace wpa_supplicant is executed instead of just once when
modprobe is executed.

Along with 'Fix for bogus data used to determine macpower',
wpa_supplicant now reliably and successfully authenticates.

For rtl8xxxu-devel branch of git.kernel.org/pub/scm/linux/kernel/git/jes/linux.git

Signed-off-by: John Heenan <john@zgus.com>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 04141e5..f25b4df 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -5779,6 +5779,11 @@ static int rtl8xxxu_start(struct ieee80211_hw *hw)
 
 	ret = 0;
 
+	ret = rtl8xxxu_init_device(hw);
+	if (ret)
+		goto error_out;
+
+
 	init_usb_anchor(&priv->rx_anchor);
 	init_usb_anchor(&priv->tx_anchor);
 	init_usb_anchor(&priv->int_anchor);
@@ -6080,10 +6085,6 @@ static int rtl8xxxu_probe(struct usb_interface *interface,
 		goto exit;
 	}
 
-	ret = rtl8xxxu_init_device(hw);
-	if (ret)
-		goto exit;
-
 	hw->wiphy->max_scan_ssids = 1;
 	hw->wiphy->max_scan_ie_len = IEEE80211_MAX_DATA_LEN;
 	hw->wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION);
-- 
2.10.1
