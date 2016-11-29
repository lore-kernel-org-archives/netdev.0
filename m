From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v4 net-next 1/7] net: mvneta: Optimize rx path for small frame
Date: Tue, 29 Nov 2016 15:55:19 +0100
Message-ID: <50c3bed2264b0755205c622e72fc5e00cbe28233.1480431285.git-series.gregory.clement@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:59135 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755002AbcK2Oza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:55:30 -0500
In-Reply-To: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For small frame reuse the phys_addr variable instead of accessing the
uncacheable value in the rx descriptor.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 87274d4ab102..1b84f746d748 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1918,7 +1918,7 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 				goto err_drop_frame;
 
 			dma_sync_single_range_for_cpu(dev->dev.parent,
-						      rx_desc->buf_phys_addr,
+						      phys_addr,
 						      MVNETA_MH_SIZE + NET_SKB_PAD,
 						      rx_bytes,
 						      DMA_FROM_DEVICE);
-- 
git-series 0.8.10
