From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 2/3] net: fec: clear all interrupt events to support i.MX6SX
Date: Wed, 10 Dec 2014 17:54:48 +0800
Message-ID: <1418205289-7730-3-git-send-email-b38611@freescale.com>
References: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0144.outbound.protection.outlook.com ([157.56.111.144]:49888
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752117AbaLJK2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 05:28:25 -0500
In-Reply-To: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For i.MX6SX FEC controller, there have interrupt mask and event
field extension. To support all SOCs FEC, we clear all interrupt
events during MAVC initial process.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e8c7c82..c045f67 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -940,7 +940,7 @@ fec_restart(struct net_device *ndev)
 	}
 
 	/* Clear any outstanding interrupt. */
-	writel(0xffc00000, fep->hwp + FEC_IEVENT);
+	writel(0xffffffff, fep->hwp + FEC_IEVENT);
 
 	fec_enet_bd_init(ndev);
 
-- 
1.7.8
