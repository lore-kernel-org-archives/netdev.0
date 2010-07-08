From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v4 7/9] usb/atm/cxacru.c: call atm_dev_signal_change() when signal changes.
Date: Thu,  8 Jul 2010 10:34:53 +0200
Message-ID: <1278578095-25324-8-git-send-email-karl@hiramoto.org>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdccah.dreamhost.com ([208.97.132.207]:57521 "EHLO
	homiemail-a36.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755303Ab0GHIfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 04:35:22 -0400
In-Reply-To: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate signal changes to upper atm layer.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/usb/atm/cxacru.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/usb/atm/cxacru.c b/drivers/usb/atm/cxacru.c
index c89990f..101ffc9 100644
--- a/drivers/usb/atm/cxacru.c
+++ b/drivers/usb/atm/cxacru.c
@@ -866,50 +866,50 @@ static void cxacru_poll_status(struct work_struct *work)
 	instance->line_status = buf[CXINF_LINE_STATUS];
 	switch (instance->line_status) {
 	case 0:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: down\n");
 		break;
 
 	case 1:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: attempting to activate\n");
 		break;
 
 	case 2:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: training\n");
 		break;
 
 	case 3:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: channel analysis\n");
 		break;
 
 	case 4:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: exchange\n");
 		break;
 
 	case 5:
 		atm_dev->link_rate = buf[CXINF_DOWNSTREAM_RATE] * 1000 / 424;
-		atm_dev->signal = ATM_PHY_SIG_FOUND;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_FOUND);
 
 		atm_info(usbatm, "ADSL line: up (%d kb/s down | %d kb/s up)\n",
 		     buf[CXINF_DOWNSTREAM_RATE], buf[CXINF_UPSTREAM_RATE]);
 		break;
 
 	case 6:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: waiting\n");
 		break;
 
 	case 7:
-		atm_dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_LOST);
 		atm_info(usbatm, "ADSL line: initializing\n");
 		break;
 
 	default:
-		atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+		atm_dev_signal_change(atm_dev, ATM_PHY_SIG_UNKNOWN);
 		atm_info(usbatm, "Unknown line state %02x\n", instance->line_status);
 		break;
 	}
-- 
1.7.1

