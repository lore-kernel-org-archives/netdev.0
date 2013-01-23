From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: Restore promisc mode on gfar_init_mac()
Date: Wed, 23 Jan 2013 12:18:36 +0200
Message-ID: <1358936316-8195-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Voncken C Acksys <cedric.voncken@acksys.fr>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:53979 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753738Ab3AWKTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 05:19:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reactivate promiscuous mode in H/W upon gfar_init_mac(), if the
net dev requires it (IFF_PROMISC flag set).
This way the promisc mode is preserved accross device reset conditions
like tx timeout, device restore, a.s.o.

Signed-off-by: Voncken C Acksys <cedric.voncken@acksys.fr>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index bffb2ed..e765b9b 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -355,6 +355,10 @@ static void gfar_init_mac(struct net_device *ndev)
 		gfar_write(&regs->rir0, DEFAULT_RIR0);
 	}
 
+	/* Restore PROMISC mode */
+	if (ndev->flags & IFF_PROMISC)
+		rctrl |= RCTRL_PROM;
+
 	if (ndev->features & NETIF_F_RXCSUM)
 		rctrl |= RCTRL_CHECKSUMMING;
 
-- 
1.6.6
