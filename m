From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Fix single MSI-X vector coalescing
Date: Sun, 11 Jul 2010 12:31:41 -0700
Message-ID: <1278876707-21390-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1312 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725Ab0GKTb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 15:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt coalescing setup code used the TG3_FLG2_USING_MSIX flag to
determine whether or not to configure the rx coalescing parameters.
This is incorrect for the single MSI-X vector case.  This patch changes
the code to look at the TG3_FLG3_ENABLE_RSS instead.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 89aa486..57dba79 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7447,7 +7447,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
 	}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
+	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)) {
 		tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
 		tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
 		tw32(HOSTCC_RXCOAL_MAXF_INT, ec->rx_max_coalesced_frames_irq);
-- 
1.6.4.4


