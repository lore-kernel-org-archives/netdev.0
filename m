From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/11] tg3: Disable MAC loopback test for CPMU
 devices
Date: Tue, 25 Jan 2011 17:58:53 -0800
Message-ID: <1296007137-23146-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3912 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654Ab1AZB7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On CPMU devices, the MAC loopback test does not test any important paths
the phy loopback test doesn't also test.  The phy loopback test is the
more comprehensive test.  This patch disables the MAC loopback test for
these devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 988861a..0f00270 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10840,9 +10840,11 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	if (loopback_mode == TG3_MAC_LOOPBACK) {
 		/* HW errata - mac loopback fails in some cases on 5780.
 		 * Normal traffic and PHY loopback are not affected by
-		 * errata.
+		 * errata.  Also, the MAC loopback test is deprecated for
+		 * all newer ASIC revisions.
 		 */
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780)
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
+		    (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
 			return 0;
 
 		mac_mode = tp->mac_mode &
-- 
1.7.2.2


