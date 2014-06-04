From: Xiubo Li <Li.Xiubo@freescale.com>
Subject: [PATCH] gianfar: Fix the section mismatch warnings.
Date: Wed, 4 Jun 2014 16:49:16 +0800
Message-ID: <1401871756-29231-1-git-send-email-Li.Xiubo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Xiubo Li <Li.Xiubo@freescale.com>
To: <claudiu.manoil@freescale.com>, <davem@davemloft.net>,
	<jingchang.lu@freescale.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building with CONFIG_DEBUG_SECTION_MISMATCH enabled, the following
WARNING is occured:

  LD      drivers/net/built-in.o
WARNING: drivers/net/built-in.o(.text+0xcd4c): Section mismatch in
reference from the function gfar_probe() to the function
.init.text:gfar_init_addr_hash_table()
The function gfar_probe() references
the function __init gfar_init_addr_hash_table().
This is often because gfar_probe lacks a __init
annotation or the annotation of gfar_init_addr_hash_table is wrong.

Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a7fe6a7..1fde3e6 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1242,7 +1242,7 @@ static void gfar_hw_init(struct gfar_private *priv)
 		gfar_write_isrg(priv);
 }
 
-static void __init gfar_init_addr_hash_table(struct gfar_private *priv)
+static void gfar_init_addr_hash_table(struct gfar_private *priv)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 
-- 
1.8.5
