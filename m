From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] sh_eth: handle only enabled E-MAC interrupts
Date: Wed, 04 Jan 2017 15:10:21 +0300
Message-ID: <3040246.Jqm8G9qTbW@wasted.cogentembedded.com>
References: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34933 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934247AbdADMKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:10:25 -0500
Received: by mail-lf0-f53.google.com with SMTP id b14so303214652lfg.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:10:24 -0800 (PST)
In-Reply-To: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver should only handle the enabled E-MAC interrupts, like it does
for the E-DMAC interrupts since commit 3893b27345ac ("sh_eth: workaround
for spurious ECI interrupt"),  so mask ECSR with  ECSIPR when reading it
in sh_eth_error().

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: renesas/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ renesas/drivers/net/ethernet/renesas/sh_eth.c
@@ -1535,7 +1535,8 @@ static void sh_eth_error(struct net_devi
 	u32 mask;
 
 	if (intr_status & EESR_ECI) {
-		felic_stat = sh_eth_read(ndev, ECSR);
+		felic_stat = sh_eth_read(ndev, ECSR) &
+			     sh_eth_read(ndev, ECSIPR);
 		sh_eth_write(ndev, felic_stat, ECSR);	/* clear int */
 		if (felic_stat & ECSR_ICD)
 			ndev->stats.tx_carrier_errors++;
