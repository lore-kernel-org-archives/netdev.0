From: Emiliano Ingrassia <ingrassia@epigenesys.com>
Subject: [PATCH] net: stmmac: dwmac_lib: fix interchanged sleep/timeout
 values in DMA reset function
Date: Thu, 12 Oct 2017 11:00:47 +0200
Message-ID: <20171012090047.GA4479@ingrassia.epigenesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35854 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdJLJEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 05:04:54 -0400
Received: by mail-wm0-f67.google.com with SMTP id 131so3576733wmk.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 02:04:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA reset timeout, used in read_poll_timeout, is
ten times shorter than the sleep time.
This patch fixes these values interchanging them, as it was
before the read_poll_timeout introduction.

Fixes: 8a70aeca80c2 ("net: stmmac: Use readl_poll_timeout")

Signed-off-by: Emiliano Ingrassia <ingrassia@epigenesys.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 67af0bdd7f10..7516ca210855 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -34,7 +34,7 @@ int dwmac_dma_reset(void __iomem *ioaddr)
 
 	err = readl_poll_timeout(ioaddr + DMA_BUS_MODE, value,
 				 !(value & DMA_BUS_MODE_SFT_RESET),
-				 100000, 10000);
+				 10000, 100000);
 	if (err)
 		return -EBUSY;
 
-- 
2.14.1
