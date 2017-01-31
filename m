From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 16/17] net: stmmac: remove unused variable in sysfs_display_ring
Date: Tue, 31 Jan 2017 10:11:51 +0100
Message-ID: <20170131091152.13842-17-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33475 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbdAaJV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:21:58 -0500
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The u64 x variable in sysfs_display_ring is unused.
This patch remove it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b494bc2..f0ce780 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2890,9 +2890,7 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 	struct dma_desc *p = (struct dma_desc *)head;
 
 	for (i = 0; i < size; i++) {
-		u64 x;
 		if (extend_desc) {
-			x = *(u64 *) ep;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
 				   le32_to_cpu(ep->basic.des0),
@@ -2901,7 +2899,6 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 				   le32_to_cpu(ep->basic.des3));
 			ep++;
 		} else {
-			x = *(u64 *) p;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
 				   le32_to_cpu(p->des0), le32_to_cpu(p->des1),
-- 
2.10.2
