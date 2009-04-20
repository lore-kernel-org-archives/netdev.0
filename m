From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/8] tg3: Restore LAA sooner in shutdown sequence
Date: Mon, 20 Apr 2009 09:58:52 -0700
Message-ID: <1240247960.7027@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3398 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229AbZDTRTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After a shutdown reset, the LAA needs to be restored before posting the
post-reset signature in shared memory.  If the LAA is not restored
before then, the bootcode will assume the factory default MAC address
and WOL will not work with the LAA.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0501fb4..f2b7ff8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2456,8 +2456,6 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		}
 	}
 
-	__tg3_set_mac_addr(tp, 0);
-
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		u32 val;
 
@@ -6357,6 +6355,8 @@ static int tg3_halt(struct tg3 *tp, int kind, int silent)
 	tg3_abort_hw(tp, silent);
 	err = tg3_chip_reset(tp);
 
+	__tg3_set_mac_addr(tp, 0);
+
 	tg3_write_sig_legacy(tp, kind);
 	tg3_write_sig_post_reset(tp, kind);
 
-- 
1.6.0.6


