From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Reduce 57765 core clock when link at
 10Mbps
Date: Mon, 12 Apr 2010 09:58:26 -0700
Message-ID: <1271091511-11173-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4896 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424Ab0DLQ6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reduces the core clock to 6.25MHz when operating at 10Mbps
link speed.  This is needed to prevent a bug that will ultimately cause
transmits to cease.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a0ab89e..3e89323 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7654,6 +7654,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		     val | TG3_PCIE_PL_LO_PHYCTL5_DIS_L2CLKREQ);
 
 		tw32(GRC_MODE, grc_mode);
+
+		val = tr32(TG3_CPMU_LSPD_10MB_CLK);
+		val &= ~CPMU_LSPD_10MB_MACCLK_MASK;
+		val |= CPMU_LSPD_10MB_MACCLK_6_25;
+		tw32(TG3_CPMU_LSPD_10MB_CLK, val);
 	}
 
 	/* This works around an issue with Athlon chipsets on
-- 
1.6.4.4


