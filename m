From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/8] tg3: Limit CLKREQ fix to A[01] of 57780 asic rev
Date: Mon, 20 Apr 2009 09:58:27 -0700
Message-ID: <1240247959.7024@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3638 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265AbZDTRTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch restricts the CLKREQ bugfix to the A0 and A1 revisions
of 57780 ASIC rev chips.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 ++-
 drivers/net/tg3.h |    2 ++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c5c3d28..0501fb4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11992,7 +11992,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0 ||
+			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A1)
 				tp->tg3_flags3 |= TG3_FLG3_CLKREQ_BUG;
 		}
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f1016cb..b3347c4 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -95,6 +95,8 @@
 #define  CHIPREV_ID_5752_A1		 0x6001
 #define  CHIPREV_ID_5714_A2		 0x9002
 #define  CHIPREV_ID_5906_A1		 0xc001
+#define  CHIPREV_ID_57780_A0		 0x57780000
+#define  CHIPREV_ID_57780_A1		 0x57780001
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
-- 
1.6.0.6


