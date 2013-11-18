From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/12 NEXT] rtlwifi: Update beacon statistics for USB driver
Date: Mon, 18 Nov 2013 11:11:31 -0600
Message-ID: <1384794696-20314-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The USB drivers were not updating the beacon statistics, which led to
false beacon loss indications.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/usb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 75481d2..2d56d90 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -483,6 +483,8 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 			if (unicast)
 				rtlpriv->link_info.num_rx_inperiod++;
 		}
+		/* static bcn for roaming */
+		rtl_beacon_statistic(hw, skb);
 	}
 }
 
-- 
1.8.4
