From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Fix the build as module
Date: Wed, 20 Mar 2013 15:19:32 -0300
Message-ID: <1363803572-17039-1-git-send-email-festevam@gmail.com>
Cc: Frank.Li@freescale.com, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:64260 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167Ab3CTSTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:19:43 -0400
Received: by mail-qa0-f53.google.com with SMTP id k4so377123qaq.19
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:19:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Since commit ff43da86c69 (NET: FEC: dynamtic check DMA desc buff type) the 
following build error happens when CONFIG_FEC=m

ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefined!
ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undefined!
ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/fec.ko] undefined!

Fix it by exporting the required fec_ptp symbols.

Reported-by: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 1f17ca0..0d8df40 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -128,6 +128,7 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
 
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 }
+EXPORT_SYMBOL(fec_ptp_start_cyclecounter);
 
 /**
  * fec_ptp_adjfreq - adjust ptp cycle frequency
@@ -318,6 +319,7 @@ int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 	    -EFAULT : 0;
 }
+EXPORT_SYMBOL(fec_ptp_ioctl);
 
 /**
  * fec_time_keep - call timecounter_read every second to avoid timer overrun
@@ -383,3 +385,4 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
 		pr_info("registered PHC device on %s\n", ndev->name);
 	}
 }
+EXPORT_SYMBOL(fec_ptp_init);
-- 
1.7.9.5
