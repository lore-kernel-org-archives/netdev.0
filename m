From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/8] qlge: Fix carrier on condition.
Date: Thu,  2 Jul 2009 09:06:08 -0700
Message-ID: <1246550773-18417-3-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbZGBQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:33 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were turning on the carrier without verifying the link was up.
This adds link up to the link initialize check before turning carrier
on.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 1da831e..c226257 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3343,7 +3343,11 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	}
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	ql_alloc_rx_buffers(qdev);
-	if ((ql_read32(qdev, STS) & qdev->port_init))
+	/* If the port is initialized and the
+	 * link is up the turn on the carrier.
+	 */
+	if ((ql_read32(qdev, STS) & qdev->port_init) &&
+			(ql_read32(qdev, STS) & qdev->port_link_up))
 		netif_carrier_on(qdev->ndev);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
-- 
1.6.0.2

