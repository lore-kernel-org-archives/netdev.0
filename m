From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] bfin_mac: use the newer CLKBUFOE bit name via asm/dpmc.h
Date: Tue, 19 Jan 2010 02:14:12 -0500
Message-ID: <1263885252-23130-1-git-send-email-vapier@gentoo.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43225 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294Ab0ASHOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 02:14:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver tweaks VR_CTL, so pull in the header for the bit defines.
Also switch to the new define name as the old one has gone away.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
note: this fixes a build error in current 2.6.33-rcX

 drivers/net/bfin_mac.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 8ffea39..0b23bc4 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -33,6 +33,7 @@
 #include <asm/dma.h>
 #include <linux/dma-mapping.h>
 
+#include <asm/dpmc.h>
 #include <asm/blackfin.h>
 #include <asm/cacheflush.h>
 #include <asm/portmux.h>
@@ -386,8 +387,8 @@ static int mii_probe(struct net_device *dev)
 	u32 sclk, mdc_div;
 
 	/* Enable PHY output early */
-	if (!(bfin_read_VR_CTL() & PHYCLKOE))
-		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
+	if (!(bfin_read_VR_CTL() & CLKBUFOE))
+		bfin_write_VR_CTL(bfin_read_VR_CTL() | CLKBUFOE);
 
 	sclk = get_sclk();
 	mdc_div = ((sclk / MDC_CLK) / 2) - 1;
-- 
1.6.6

