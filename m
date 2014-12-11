From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v2 2/3] net: fec: clear all interrupt events to support i.MX6SX
Date: Thu, 11 Dec 2014 09:20:32 +0800
Message-ID: <1418260833-896-3-git-send-email-b38611@freescale.com>
References: <1418260833-896-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0131.outbound.protection.outlook.com ([207.46.100.131]:11193
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933521AbaLKByO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 20:54:14 -0500
In-Reply-To: <1418260833-896-1-git-send-email-b38611@freescale.com>
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
index b118b7d..85c955e 100644
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
