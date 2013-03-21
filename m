From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] sh_eth: use PIR_* bits
Date: Thu, 21 Mar 2013 23:37:54 +0300
Message-ID: <201303212337.55118.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:47712 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab3CUTgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 15:36:35 -0400
Received: by mail-la0-f43.google.com with SMTP id ek20so5926578lab.16
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 12:36:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sh_mdio_init() uses the bare numbers instead of the PHY interface bits, despite
these are declared in sh_eth.h as 'enum PIR_BIT'...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2254,10 +2254,10 @@ static int sh_mdio_init(struct net_devic
 	/* bitbang init */
 	bitbang->addr = mdp->addr + mdp->reg_offset[PIR];
 	bitbang->set_gate = pd->set_mdio_gate;
-	bitbang->mdi_msk = 0x08;
-	bitbang->mdo_msk = 0x04;
-	bitbang->mmd_msk = 0x02;/* MMD */
-	bitbang->mdc_msk = 0x01;
+	bitbang->mdi_msk = PIR_MDI;
+	bitbang->mdo_msk = PIR_MDO;
+	bitbang->mmd_msk = PIR_MMD;
+	bitbang->mdc_msk = PIR_MDC;
 	bitbang->ctrl.ops = &bb_ops;
 
 	/* MII controller setting */
