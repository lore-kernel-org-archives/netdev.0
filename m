From: Andreas Schwab <schwab@linux-m68k.org>
Subject: [PATCH] net/cxgb3: remove undefined operations
Date: Sat, 11 Sep 2010 13:12:34 +0200
Message-ID: <m2mxrofs9p.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:49084 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab0IKLMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 07:12:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modifying an object twice without an intervening sequence point is
undefined.

Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>
---
 drivers/net/cxgb3/t3_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 427c451..997b14b 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3682,7 +3682,7 @@ static void mc7_prep(struct adapter *adapter, struct mc7 *mc7,
 	mc7->name = name;
 	mc7->offset = base_addr - MC7_PMRX_BASE_ADDR;
 	cfg = t3_read_reg(adapter, mc7->offset + A_MC7_CFG);
-	mc7->size = mc7->size = G_DEN(cfg) == M_DEN ? 0 : mc7_calc_size(cfg);
+	mc7->size = G_DEN(cfg) == M_DEN ? 0 : mc7_calc_size(cfg);
 	mc7->width = G_WIDTH(cfg);
 }
 
-- 
1.7.2.3

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
