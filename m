From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/20] tg3: Don't touch RCB nic addresses
Date: Fri, 13 Nov 2009 15:03:34 -0800
Message-ID: <1258153432-7036-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4579 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932462AbZKMXES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch avoids reprogramming the RCB NIC addresses for all 5755 and
later devices.  The address is incorrect for 5717 devices and should be
correct by default for all other affected devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fc9df25..e1f4a18 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7404,8 +7404,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	     ((u64) tpr->rx_std_mapping >> 32));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tpr->rx_std_mapping & 0xffffffff));
-	tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
-	     NIC_SRAM_RX_BUFFER_DESC);
+	if (!(tp->tg3_flags3 & TG3_FLG3_5755_PLUS))
+		tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
+		     NIC_SRAM_RX_BUFFER_DESC);
 
 	/* Disable the mini ring */
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
@@ -7428,8 +7429,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
 			     (RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT) |
 			     BDINFO_FLAGS_USE_EXT_RECV);
-			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
-			     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
+			if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+				tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
+				     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
 		} else {
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
 			     BDINFO_FLAGS_DISABLED);
-- 
1.6.4.4


