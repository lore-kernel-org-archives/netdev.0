From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] bnx2x: new features patch series
Date: Thu, 26 Dec 2013 18:33:37 -0500 (EST)
Message-ID: <20131226.183337.1915444723736545207.davem@davemloft.net>
References: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
	<20131226.133853.2211726123097632477.davem@davemloft.net>
	<1388085227.12212.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, ariele@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891Ab3LZXdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 18:33:38 -0500
In-Reply-To: <1388085227.12212.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Dec 2013 11:13:47 -0800

> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function 'bnx2x_drv_info_ether_stat':
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3302:46: error: dereferencing pointer to incomplete type
> make[6]: *** [drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.o] Error 1

Fixing this like the following for now, thanks:

--------------------
[PATCH] bnx2x: Fix build with SRIOV disabled.

drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function 'bnx2x_drv_info_ether_stat':
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3302:46: error: dereferencing pointer to incomplete type
make[6]: *** [drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.o] Error 1

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 094dfc8..d3748bf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3299,7 +3299,9 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)
 	ether_stat->txq_size = bp->tx_ring_size;
 	ether_stat->rxq_size = bp->rx_ring_size;
 
+#ifdef CONFIG_BNX2X_SRIOV
 	ether_stat->vf_cnt = IS_SRIOV(bp) ? bp->vfdb->sriov.nr_virtfn : 0;
+#endif
 }
 
 static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
-- 
1.7.11.7
