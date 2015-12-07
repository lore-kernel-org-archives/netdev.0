From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] sh_eth: remove mask fields from 'struct bb_info'
Date: Tue, 08 Dec 2015 00:40:19 +0300
Message-ID: <8193175.UjRYeBy7vc@wasted.cogentembedded.com>
References: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36817 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756013AbbLGVkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 16:40:22 -0500
Received: by lfs39 with SMTP id 39so275365lfs.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 13:40:21 -0800 (PST)
In-Reply-To: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO control bits are always mapped to the same bits of the same register
(PIR), so there's no need to store their masks in the 'struct bb_info'...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1013,10 +1013,6 @@ struct bb_info {
 	void (*set_gate)(void *addr);
 	struct mdiobb_ctrl ctrl;
 	void *addr;
-	u32 mmd_msk;/* MMD */
-	u32 mdo_msk;
-	u32 mdi_msk;
-	u32 mdc_msk;
 };
 
 /* PHY bit set */
@@ -1046,9 +1042,9 @@ static void sh_mmd_ctrl(struct mdiobb_ct
 		bitbang->set_gate(bitbang->addr);
 
 	if (bit)
-		bb_set(bitbang->addr, bitbang->mmd_msk);
+		bb_set(bitbang->addr, PIR_MMD);
 	else
-		bb_clr(bitbang->addr, bitbang->mmd_msk);
+		bb_clr(bitbang->addr, PIR_MMD);
 }
 
 /* Set bit data*/
@@ -1060,9 +1056,9 @@ static void sh_set_mdio(struct mdiobb_ct
 		bitbang->set_gate(bitbang->addr);
 
 	if (bit)
-		bb_set(bitbang->addr, bitbang->mdo_msk);
+		bb_set(bitbang->addr, PIR_MDO);
 	else
-		bb_clr(bitbang->addr, bitbang->mdo_msk);
+		bb_clr(bitbang->addr, PIR_MDO);
 }
 
 /* Get bit data*/
@@ -1073,7 +1069,7 @@ static int sh_get_mdio(struct mdiobb_ctr
 	if (bitbang->set_gate)
 		bitbang->set_gate(bitbang->addr);
 
-	return bb_read(bitbang->addr, bitbang->mdi_msk);
+	return bb_read(bitbang->addr, PIR_MDI);
 }
 
 /* MDC pin control */
@@ -1085,9 +1081,9 @@ static void sh_mdc_ctrl(struct mdiobb_ct
 		bitbang->set_gate(bitbang->addr);
 
 	if (bit)
-		bb_set(bitbang->addr, bitbang->mdc_msk);
+		bb_set(bitbang->addr, PIR_MDC);
 	else
-		bb_clr(bitbang->addr, bitbang->mdc_msk);
+		bb_clr(bitbang->addr, PIR_MDC);
 }
 
 /* mdio bus control struct */
@@ -2899,10 +2895,6 @@ static int sh_mdio_init(struct sh_eth_pr
 	/* bitbang init */
 	bitbang->addr = mdp->addr + mdp->reg_offset[PIR];
 	bitbang->set_gate = pd->set_mdio_gate;
-	bitbang->mdi_msk = PIR_MDI;
-	bitbang->mdo_msk = PIR_MDO;
-	bitbang->mmd_msk = PIR_MMD;
-	bitbang->mdc_msk = PIR_MDC;
 	bitbang->ctrl.ops = &bb_ops;
 
 	/* MII controller setting */
