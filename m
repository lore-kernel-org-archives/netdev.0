From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/10] tg3: Allow GPHY powerdown on 5761
Date: Fri, 21 Nov 2008 11:02:15 -0800
Message-ID: <1227295576.5624@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4673 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178AbYKUT0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ENABLE_APE flag tells the driver whether or not the device has an
Application Processing Engine (APE).  The APE does not need the PHY to
be powered unless it is running management firmware.  For backwards
compatibility, management firmware will still set the ENABLE_ASF bit.
Consequently, there is no reason to consider the ENABLE_APE flag when
deciding whether or not to power down the phy.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 89d897d..07bf056 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2400,8 +2400,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 	}
 
 	if (!(device_should_wake) &&
-	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
-	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
 		tg3_power_down_phy(tp, do_low_power);
 
 	tg3_frob_aux_power(tp);
-- 
1.5.6.4



