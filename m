From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: [PATCH] dp83640: Fix NOHZ local_softirq_pending 08 warning
Date: Thu, 12 Jan 2012 12:58:05 +0100
Message-ID: <1326369485-6218-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <stable@vger.kernel.org>,
	<richardcochran@gmail.com>,
	Manfred Rudigier <manfred.rudigier@omicron.at>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:37874 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab2ALMIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 07:08:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar problem as in 481a8199142c050b72bff8a1956a49fd0a75bbe0. This fix
replaces netif_rx() with netif_rx_ni() which has to be used from
process/softirq context.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/phy/dp83640.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 9663e0b..ba3c591 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1159,7 +1159,7 @@ static void rx_timestamp_work(struct work_struct *work)
 			}
 		}
 		spin_unlock_irqrestore(&dp83640->rx_lock, flags);
-		netif_rx(skb);
+		netif_rx_ni(skb);
 	}
 
 	/* Clear out expired time stamps. */
-- 
1.7.0.4
