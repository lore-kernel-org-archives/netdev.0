From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 09/11] RFC: dummy: bulk free SKBs
Date: Tue, 02 Feb 2016 22:14:49 +0100
Message-ID: <20160202211414.16315.92872.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbcBBVOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:14:50 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normal TX completion uses napi_consume_skb(), thus also make dummy driver
use this, as it make it easier to see the effect of bulk freeing SKBs.

---
 drivers/net/dummy.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 69fc8409a973..985565ec5d60 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -85,7 +85,8 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	dstats->tx_bytes += skb->len;
 	u64_stats_update_end(&dstats->syncp);
 
-	dev_kfree_skb(skb);
+	//dev_kfree_skb(skb);
+	napi_consume_skb(skb, 1);
 	return NETDEV_TX_OK;
 }
 
