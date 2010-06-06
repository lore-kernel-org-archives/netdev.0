From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/10] tg3: Avoid tx lockups on 5755+ devices
Date: Sat, 5 Jun 2010 20:24:31 -0700
Message-ID: <1275794679-11085-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2238 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933998Ab0FFDY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In certain edge conditions, internal tx resources can get corrupted.
This patch enables a bit that will fix the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 drivers/net/tg3.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bd33117..057e8eb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8214,6 +8214,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	tp->tx_mode = TX_MODE_ENABLE;
+	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		tp->tx_mode |= TX_MODE_MBUF_LOCKUP_FIX;
 	tw32_f(MAC_TX_MODE, tp->tx_mode);
 	udelay(100);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 84ea0dc..c245e80 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -469,6 +469,7 @@
 #define  TX_MODE_FLOW_CTRL_ENABLE	 0x00000010
 #define  TX_MODE_BIG_BCKOFF_ENABLE	 0x00000020
 #define  TX_MODE_LONG_PAUSE_ENABLE	 0x00000040
+#define  TX_MODE_MBUF_LOCKUP_FIX	 0x00000100
 #define MAC_TX_STATUS			0x00000460
 #define  TX_STATUS_XOFFED		 0x00000001
 #define  TX_STATUS_SENT_XOFF		 0x00000002
-- 
1.6.4.4


