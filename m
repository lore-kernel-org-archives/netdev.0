From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/13] tg3: Fix IPv6 TCP problems for 5719
Date: Thu, 19 May 2011 15:12:47 -0700
Message-ID: <1305843176-32358-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1098 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934865Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4d163b75e979833979cc401ae433cb1d7743d57e, entitled
"tg3: Fix 5719 A0 tx completion bug" turned off TSO to fix a hardware
bug.  In doing so, it accidentally turned off all IPv6 TCP checksum
offloading too.  This patch fixes the problem by reenabling the hardware
bit that control both features.  The TSO capability is still not exposed
to the kernel.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 09f2c11..6c53e2c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8303,7 +8303,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    tg3_flag(tp, HW_TSO_3))
 		rdmac_mode |= RDMAC_MODE_IPV4_LSO_EN;
 
-	if (tg3_flag(tp, HW_TSO_3) ||
+	if (tg3_flag(tp, 57765_PLUS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		rdmac_mode |= RDMAC_MODE_IPV6_LSO_EN;
-- 
1.7.3.4


