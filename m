From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/10] tg3: Supply a nicaddr for 57765 jumbo
 RCB
Date: Wed, 20 Jan 2010 18:58:07 -0800
Message-ID: <1264042691-28284-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1745 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab0AUC61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 57765 needs the driver to supply a nic address to the jumbo RCB,
just like all other devices except the 5717.  This patch changes the
test to single out the 5717 rather than maintain a lengthy whitelist of
asic revs.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 44ac9e2..72d1e18 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7787,7 +7787,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
 			     (RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT) |
 			     BDINFO_FLAGS_USE_EXT_RECV);
-			if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717)
 				tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
 				     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
 		} else {
-- 
1.6.4.4


