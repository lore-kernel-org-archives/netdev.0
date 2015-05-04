From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 5/6] hisilicon: Replace
 put_page(virt_to_head_page()) with skb_free_frag()
Date: Mon, 04 May 2015 16:15:11 -0700
Message-ID: <20150504231511.1538.48064.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net
To: linux-mm@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbbEDXPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 19:15:12 -0400
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 3b39fdddeb57..d49bee38cd31 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -798,7 +798,7 @@ static void hip04_free_ring(struct net_device *ndev, struct device *d)
 
 	for (i = 0; i < RX_DESC_NUM; i++)
 		if (priv->rx_buf[i])
-			put_page(virt_to_head_page(priv->rx_buf[i]));
+			skb_free_frag(priv->rx_buf[i]);
 
 	for (i = 0; i < TX_DESC_NUM; i++)
 		if (priv->tx_skb[i])
