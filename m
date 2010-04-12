From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/8] tg3: Unify max pkt size preprocessor
 constants
Date: Mon, 12 Apr 2010 09:58:29 -0700
Message-ID: <1271091511-11173-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4903 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752881Ab0DLQ6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum packet size that gets programmed into the standard producer
ring control block is directly related to the packet size used to
allocate packet buffers.  This patch removes the redundant preprocessor
constant.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 drivers/net/tg3.h |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3263f50..a331ec5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7905,9 +7905,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 			val = (RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT) |
-			      (RX_STD_MAX_SIZE << 2);
+			      (TG3_RX_STD_DMA_SZ << 2);
 		else
-			val = RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT;
+			val = TG3_RX_STD_DMA_SZ << BDINFO_FLAGS_MAXLEN_SHIFT;
 	} else
 		val = RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT;
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 43dd1d2..b71083d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -25,7 +25,6 @@
 
 #define TG3_RX_INTERNAL_RING_SZ_5906	32
 
-#define RX_STD_MAX_SIZE			1536
 #define RX_STD_MAX_SIZE_5705		512
 #define RX_JUMBO_MAX_SIZE		0xdeadbeef /* XXX */
 
-- 
1.6.4.4


