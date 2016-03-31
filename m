From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Do not access unexisting register in Coldfire
Date: Thu, 31 Mar 2016 12:05:17 -0300
Message-ID: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
	gerg@uclinux.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:36150 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317AbcCaPF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 11:05:59 -0400
Received: by mail-yw0-f181.google.com with SMTP id g3so100861931ywa.3
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 08:05:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

Commit 55cd48c821de ("net: fec: stop the "rcv is not +last, " error
messages") introduces a write to a register that does not exist in
Coldfire.

Move the FEC_FTRL register access inside the FEC_QUIRK_HAS_RACC 'if' block,
so that we guarantee it will not be used on Coldfire CPUs.

Reported-by: Greg Ungerer <gerg@uclinux.org>
Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 37c0815..08243c2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -943,8 +943,8 @@ fec_restart(struct net_device *ndev)
 		else
 			val &= ~FEC_RACC_OPTIONS;
 		writel(val, fep->hwp + FEC_RACC);
+		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
 	}
-	writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
 #endif
 
 	/*
-- 
1.9.1
