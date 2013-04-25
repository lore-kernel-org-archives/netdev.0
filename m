From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH-NEXT] rtlwifi: rtl8192cu: Fix false loss of AP indication
Date: Thu, 25 Apr 2013 09:50:28 -0500
Message-ID: <1366901428-21307-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:46102 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932559Ab3DYOuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 10:50:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A major change in the rtlwifi family recently added code to detect when
there is loss of AP signals. One critical statement needed for the USB
driver was missed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

John,

Sorry to be so late, but this problem was just discovered.

Larry
---

 drivers/net/wireless/rtlwifi/usb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 83915dc..76732b0 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -521,6 +521,9 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 				rtlpriv->link_info.num_rx_inperiod++;
 		}
 
+		/* static bcn for roaming */
+		rtl_beacon_statistic(hw, skb);
+
 		if (likely(rtl_action_proc(hw, skb, false)))
 			ieee80211_rx(hw, skb);
 		else
-- 
1.8.1.4
