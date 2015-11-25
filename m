From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] drivers: net: xgene: fix possible use after free
Date: Wed, 25 Nov 2015 09:02:10 -0800
Message-ID: <1448470930.24696.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151125155753.GE12434@leverpostej>
	 <1448468256.24696.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151125163402.GA29094@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isubramanian@apm.com, kchudgar@apm.com,
	linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Mark Rutland <mark.rutland@arm.com>,
	David Miller <davem@davemloft.net>,
	Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151125163402.GA29094@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Once TX has been enabled on a NIC, it is illegal to access skb,
as this skb might have been freed by another cpu, from TX completion
handler.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Cc: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 1adfe7036843..9147a0107c44 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -450,12 +450,12 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	pdata->ring_ops->wr_cmd(tx_ring, count);
 	skb_tx_timestamp(skb);
 
 	pdata->stats.tx_packets++;
 	pdata->stats.tx_bytes += skb->len;
 
+	pdata->ring_ops->wr_cmd(tx_ring, count);
 	return NETDEV_TX_OK;
 }
 
