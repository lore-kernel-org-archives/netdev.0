From: Valentin Longchamp <valentin.longchamp@keymile.com>
Subject: [PATCH v2] net/ethernet/freescale: fix warning for ucc_geth
Date: Fri, 15 Sep 2017 07:58:47 +0200
Message-ID: <20170915055847.29716-1-valentin.longchamp@keymile.com>
Cc: linuxppc-dev@lists.ozlabs.org,
        Valentin Longchamp <valentin.longchamp@keymile.com>
To: leoli@freescale.com, netdev@vger.kernel.org,
        christophe.leroy@c-s.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:38331 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdIOF6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 01:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

uf_info.regs is resource_size_t i.e. phys_addr_t that can be either u32
or u64 according to CONFIG_PHYS_ADDR_T_64BIT.

The printk format is thus adaptet to u64 and the regs value cast to u64
to take both u32 and u64 into account.

Signed-off-by: Valentin Longchamp <valentin.longchamp@keymile.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index f77ba9fa257b..a96b838cffce 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3857,8 +3857,9 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	}
 
 	if (netif_msg_probe(&debug))
-		pr_info("UCC%1d at 0x%8x (irq = %d)\n",
-			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
+		pr_info("UCC%1d at 0x%8llx (irq = %d)\n",
+			ug_info->uf_info.ucc_num + 1,
+			(u64)ug_info->uf_info.regs,
 			ug_info->uf_info.irq);
 
 	/* Create an ethernet device instance */
-- 
2.13.5
