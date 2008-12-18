From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/5] tg3: WOL fixes
Date: Wed, 17 Dec 2008 16:33:37 -0800
Message-ID: <1229717357.5496@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1128 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169AbYLSUJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 15:09:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first hunk of this patch inverts a flag that was accidentally
toggled as part of commit 0a459aac9d151c2e36ec65723b9b845b24c5cbc3.

The second hunk of the patch removes the call to
device_may_wakeup() in the 5906 config detection path.  At the
point of the call, the driver shouldn't be querying for WOL
capability.  It should be detecting and setting it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 06bd2f4..bacbfc5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2237,7 +2237,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			}
 		}
 	} else {
-		do_low_power = false;
+		do_low_power = true;
 
 		if (tp->link_config.phy_is_low_power == 0) {
 			tp->link_config.phy_is_low_power = 1;
@@ -11544,8 +11544,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (val & VCPU_CFGSHDW_ASPM_DBNC)
 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
-		    (val & VCPU_CFGSHDW_WOL_MAGPKT) &&
-		    device_may_wakeup(&tp->pdev->dev))
+		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
 		goto done;
 	}
-- 
1.5.6.4


