From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v4 net-next 2/7] net: mvneta: Do not allocate buffer in rxq init with HWBM
Date: Tue, 29 Nov 2016 15:55:20 +0100
Message-ID: <bbbf71fd39c93227248df0ec91fabfb29ba0e778.1480431285.git-series.gregory.clement@free-electrons.com>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:59148 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757675AbcK2Oza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:55:30 -0500
In-Reply-To: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For HWBM all buffers are allocated in mvneta_bm_construct() and in runtime
they are put into descriptors by hardware. There is no need to fill them
at this point.

Suggested-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 1b84f746d748..f5319c50f8d9 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2784,14 +2784,14 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 		mvneta_rxq_buf_size_set(pp, rxq,
 					MVNETA_RX_BUF_SIZE(pp->pkt_size));
 		mvneta_rxq_bm_disable(pp, rxq);
+		mvneta_rxq_fill(pp, rxq, rxq->size);
 	} else {
 		mvneta_rxq_bm_enable(pp, rxq);
 		mvneta_rxq_long_pool_set(pp, rxq);
 		mvneta_rxq_short_pool_set(pp, rxq);
+		mvneta_rxq_non_occup_desc_add(pp, rxq, rxq->size);
 	}
 
-	mvneta_rxq_fill(pp, rxq, rxq->size);
-
 	return 0;
 }
 
-- 
git-series 0.8.10
