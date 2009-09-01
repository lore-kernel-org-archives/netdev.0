From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Use 32bit read to read Y2_VAUX_AVAIL
Date: Tue, 01 Sep 2009 22:54:27 +0900
Message-ID: <4A9D2793.1020502@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f203.google.com ([209.85.216.203]:63674 "EHLO
	mail-px0-f203.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827AbZIAN6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 09:58:25 -0400
Received: by pxi42 with SMTP id 42so2272pxi.20
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 06:58:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

B0_CTST is a 24bit register according to the vendor driver (sk98lin).
A 16bit read on B0_CTST will always return 0 for Y2_VAUX_AVAIL (1<<16),
 so use a 32bit read when testing Y2_VAUX_AVAIL

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 +-
 drivers/net/sky2.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7108b12..d1f3b46 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -273,7 +273,7 @@ static void sky2_power_aux(struct sky2_hw *hw)
 			    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
 
 	/* switch power to VAUX */
-	if (sky2_read16(hw, B0_CTST) & Y2_VAUX_AVAIL)
+	if (sky2_read32(hw, B0_CTST) & Y2_VAUX_AVAIL)
 		sky2_write8(hw, B0_POWER_CTRL,
 			    (PC_VAUX_ENA | PC_VCC_ENA |
 			     PC_VAUX_ON | PC_VCC_OFF));
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 34042ff..e0f23a1 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -260,7 +260,7 @@ enum csr_regs {
 	Y2_CFG_AER      = 0x1d00,	/* PCI Advanced Error Report region */
 };
 
-/*	B0_CTST			16 bit	Control/Status register */
+/*	B0_CTST			24 bit	Control/Status register */
 enum {
 	Y2_VMAIN_AVAIL	= 1<<17,/* VMAIN available (YUKON-2 only) */
 	Y2_VAUX_AVAIL	= 1<<16,/* VAUX available (YUKON-2 only) */
-- 
1.5.6.5

