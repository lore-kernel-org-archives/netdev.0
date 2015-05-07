From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 09/10] hisilicon: Replace put_page(virt_to_head_page()) with
 skb_free_frag()
Date: Wed, 06 May 2015 21:12:25 -0700
Message-ID: <20150507041225.1873.74253.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbbEGEMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 00:12:33 -0400
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
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
