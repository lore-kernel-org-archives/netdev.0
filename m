From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v6 net-next 1/7] net: mvneta: Optimize rx path for small frame
Date: Thu,  1 Dec 2016 18:03:04 +0100
Message-ID: <d9085595bfc823eda9bc590252b353f056c5eb65.1480611779.git-series.gregory.clement@free-electrons.com>
References: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
References: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For small frame reuse the phys_addr variable instead of accessing the
uncacheable value in the rx descriptor.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
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
