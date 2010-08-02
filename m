From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/14] tg3: Manage gphy power for CPMU-less
 devs only
Date: Mon, 2 Aug 2010 14:25:59 -0700
Message-ID: <1280784368-4226-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1404 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085Ab0HBV0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the code to only manage the PCIe gphy power for
CPMU-less devices only.  The CPMU takes over management for newer
chips.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5d155c5..38979f2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6948,8 +6948,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 		     tr32(GRC_VCPU_EXT_CTRL) & ~GRC_VCPU_EXT_CTRL_HALT_CPU);
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+	/* Manage gphy power for all CPMU absent PCIe devices. */
+	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	    !(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
 		val |= GRC_MISC_CFG_KEEP_GPHY_POWER;
+
 	tw32(GRC_MISC_CFG, val);
 
 	/* restore 5701 hardware bug workaround write method */
-- 
1.7.1


