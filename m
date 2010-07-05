From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v2 8/9] usb/atm/speedtch.c: call atm_dev_signal_change() when signal changes.
Date: Mon,  5 Jul 2010 10:46:00 +0200
Message-ID: <1278319561-23548-9-git-send-email-karl@hiramoto.org>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:33287 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758166Ab0GEIr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 04:47:59 -0400
Received: from homiemail-a30.g.dreamhost.com (caiajhbdcaid.dreamhost.com [208.97.132.83])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 831A817A440
	for <netdev@vger.kernel.org>; Mon,  5 Jul 2010 01:47:57 -0700 (PDT)
In-Reply-To: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate signal changes to upper atm layer.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/usb/atm/speedtch.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/atm/speedtch.c b/drivers/usb/atm/speedtch.c
index 1335456..80f9617 100644
--- a/drivers/usb/atm/speedtch.c
+++ b/drivers/usb/atm/speedtch.c
@@ -525,7 +525,7 @@ static void speedtch_check_status(struct work_struct *work)
 
 		switch (status) {
 		case 0:
-			atm_dev->signal = ATM_PHY_SIG_LOST;
+			atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 			if (instance->last_status)
 				atm_info(usbatm, "ADSL line is down\n");
 			/* It may never resync again unless we ask it to... */
@@ -533,12 +533,12 @@ static void speedtch_check_status(struct work_struct *work)
 			break;
 
 		case 0x08:
-			atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+			atm_dev_signal_change(atm_dev, ATM_PHY_SIG_UNKNOWN);
 			atm_info(usbatm, "ADSL line is blocked?\n");
 			break;
 
 		case 0x10:
-			atm_dev->signal = ATM_PHY_SIG_LOST;
+			atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 			atm_info(usbatm, "ADSL line is synchronising\n");
 			break;
 
@@ -554,7 +554,7 @@ static void speedtch_check_status(struct work_struct *work)
 			}
 
 			atm_dev->link_rate = down_speed * 1000 / 424;
-			atm_dev->signal = ATM_PHY_SIG_FOUND;
+			atm_dev_signal_change(atm_dev, ATM_PHY_SIG_FOUND);
 
 			atm_info(usbatm,
 				 "ADSL line is up (%d kb/s down | %d kb/s up)\n",
@@ -562,7 +562,7 @@ static void speedtch_check_status(struct work_struct *work)
 			break;
 
 		default:
-			atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+			atm_dev_signal_change(atm_dev, ATM_PHY_SIG_UNKNOWN);
 			atm_info(usbatm, "unknown line state %02x\n", status);
 			break;
 		}
-- 
1.7.1

