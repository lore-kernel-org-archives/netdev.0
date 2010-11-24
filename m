From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/10] tg3: Assign correct tx margin for 5719
Date: Wed, 24 Nov 2010 10:31:46 -0800
Message-ID: <1290623514-18193-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3921 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab0KXScN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d309a46e42542223946d3a9e4e239fdc945cb53e, entitled
"tg3: 5719: Prevent tx data corruption", was supposed to contain the tx
margin adjustment but it looks like it somehow was omitted.  This patch
fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++++
 drivers/net/tg3.h |    2 ++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ca6b3cb..4dc0756 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8206,6 +8206,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
 	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+			val &= ~TG3_RDMA_RSRVCTRL_TXMRGN_MASK;
+			val |= TG3_RDMA_RSRVCTRL_TXMRGN_320B;
+		}
 		tw32(TG3_RDMA_RSRVCTRL_REG,
 		     val | TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX);
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 4a19748..06a4e7e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1327,6 +1327,8 @@
 
 #define TG3_RDMA_RSRVCTRL_REG		0x00004900
 #define TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX	 0x00000004
+#define TG3_RDMA_RSRVCTRL_TXMRGN_320B	 0x28000000
+#define TG3_RDMA_RSRVCTRL_TXMRGN_MASK	 0xffe00000
 /* 0x4904 --> 0x4910 unused */
 
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL	0x00004910
-- 
1.7.2.2


