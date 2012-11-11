From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v2 3/3] net/macb: clear unused address register
Date: Mon, 12 Nov 2012 00:56:28 +0100
Message-ID: <1352678188-18647-4-git-send-email-manabian@gmail.com>
References: <1352678188-18647-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41155 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab2KKX4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 18:56:35 -0500
Received: by mail-lb0-f174.google.com with SMTP id n3so4243267lbo.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 15:56:34 -0800 (PST)
In-Reply-To: <1352678188-18647-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the first register set is used for matching but
we support getting the initial hw addr from any of
the registers.

To prevent stale entries and false matches clear unused
register sets. This most important for the at91_ether
driver where u-boot always uses the 2nd register set.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 ++++++++
 drivers/net/ethernet/cadence/macb.h | 6 ++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ca34efc..edb2aba 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -108,6 +108,14 @@ void macb_set_hwaddr(struct macb *bp)
 	macb_or_gem_writel(bp, SA1B, bottom);
 	top = cpu_to_le16(*((u16 *)(bp->dev->dev_addr + 4)));
 	macb_or_gem_writel(bp, SA1T, top);
+
+	/* Clear unused address register sets */
+	macb_or_gem_writel(bp, SA2B, 0);
+	macb_or_gem_writel(bp, SA2T, 0);
+	macb_or_gem_writel(bp, SA3B, 0);
+	macb_or_gem_writel(bp, SA3T, 0);
+	macb_or_gem_writel(bp, SA4B, 0);
+	macb_or_gem_writel(bp, SA4T, 0);
 }
 EXPORT_SYMBOL_GPL(macb_set_hwaddr);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 864e380..4414421 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -74,6 +74,12 @@
 #define GEM_HRT					0x0084
 #define GEM_SA1B				0x0088
 #define GEM_SA1T				0x008C
+#define GEM_SA2B				0x0090
+#define GEM_SA2T				0x0094
+#define GEM_SA3B				0x0098
+#define GEM_SA3T				0x009C
+#define GEM_SA4B				0x00A0
+#define GEM_SA4T				0x00A4
 #define GEM_OTX					0x0100
 #define GEM_DCFG1				0x0280
 #define GEM_DCFG2				0x0284
-- 
1.8.0
