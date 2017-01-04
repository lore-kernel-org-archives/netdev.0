From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix EESIPR values for SH77{34|63}
Date: Wed, 04 Jan 2017 22:18:24 +0300
Message-ID: <1819012.0ROIJmx7mp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35577 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967484AbdADTS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:18:28 -0500
Received: by mail-lf0-f43.google.com with SMTP id b14so310608267lfg.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 11:18:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the SH77{34|63} manuals are freely available,  I've checked the EESIPR
values written against the manuals, and they appeared to set the reserved
bits 11-15 (which should be 0 on write). Fix those EESIPR values.

Fixes: 380af9e390ec ("net: sh_eth: CPU dependency code collect to "struct sh_eth_cpu_data"")
Fixes: f5d12767c8fd ("sh_eth: get SH77{34|63} support out of #ifdef")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -802,7 +802,7 @@ static struct sh_eth_cpu_data sh7734_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003f07ff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -831,7 +831,7 @@ static struct sh_eth_cpu_data sh7763_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003f07ff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
