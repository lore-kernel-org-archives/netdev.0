From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/11 NEXT] rtlwifi: Remove extra workqueue for enter/leave power state
Date: Mon, 22 Sep 2014 09:39:18 -0500
Message-ID: <1411396767-20611-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:54016 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020AbaIVOj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:39:56 -0400
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the rtlwifi family of drivers was converted to use a workqueue when
entering or leaving power save mode (commits a269913c52, a5ffbe0a19,
41affd5286, b9116b9a2b, and 6539306b2c), the code began scheduling work from
the callback routine of a different workqueue with a resulting increase in
overhead.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/base.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 93bb384..3b599b6 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1401,12 +1401,9 @@ void rtl_watchdog_wq_callback(void *data)
 		if (((rtlpriv->link_info.num_rx_inperiod +
 		      rtlpriv->link_info.num_tx_inperiod) > 8) ||
 		    (rtlpriv->link_info.num_rx_inperiod > 2))
-			rtlpriv->enter_ps = true;
+			rtl_lps_enter(hw);
 		else
-			rtlpriv->enter_ps = false;
-
-		/* LeisurePS only work in infra mode. */
-		schedule_work(&rtlpriv->works.lps_change_work);
+			rtl_lps_leave(hw);
 	}
 
 	rtlpriv->link_info.num_rx_inperiod = 0;
-- 
1.8.4.5
