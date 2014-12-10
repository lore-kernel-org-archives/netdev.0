From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 3/3] net: fec: only enable mdio interrupt before phy device link up
Date: Wed, 10 Dec 2014 17:54:49 +0800
Message-ID: <1418205289-7730-4-git-send-email-b38611@freescale.com>
References: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0126.outbound.protection.outlook.com ([207.46.100.126]:8647
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752779AbaLJK21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 05:28:27 -0500
In-Reply-To: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before phy device link up, we only enable FEC mdio interrupt, which
is more reasonable.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index c045f67..ea71bc8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1075,7 +1075,10 @@ fec_restart(struct net_device *ndev)
 		fec_ptp_start_cyclecounter(ndev);
 
 	/* Enable interrupts we wish to service */
-	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	if (fep->link)
+		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	else
+		writel(FEC_ENET_MII, fep->hwp + FEC_IMASK);
 
 	/* Init the interrupt coalescing */
 	fec_enet_itr_coal_init(ndev);
-- 
1.7.8
