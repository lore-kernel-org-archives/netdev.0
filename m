From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH net-next 2/5] net, scsi/csgb4i: convert skb->transport_header into skb_transport_header(skb)
Date: Fri, 14 Jun 2013 17:58:32 +0900
Message-ID: <7ae8c4225b5d19a2ad7d621bc7e08a74b1b4583e.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, Simon Horman <horms@verge.net.au>,
	Li RongQing <roy.qing.li@gmail.com>, linux-scsi@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The change set of 1a37e412, "net: Use 16bits for *_headers fields
of struct skbuff" converted from sk_buff_data_t into 16bit integer.
So skb->tail needs to be converted to skb_tail_pointer(skb).

Found by inspection. Compile tested only.

Cc: Simon Horman <horms@verge.net.au>
Cc: Li RongQing <roy.qing.li@gmail.com>
Cc: linux-scsi@vger.kernel.org
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 3fecf35..9138d4e 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -358,7 +358,7 @@ static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
 		return DIV_ROUND_UP(skb->len, 8);
 	flits = skb_transport_offset(skb) / 8;
 	cnt = skb_shinfo(skb)->nr_frags;
-	if (skb->tail != skb->transport_header)
+	if (skb_tail_pointer(skb) != skb_transport_header(skb))
 		cnt++;
 	return flits + sgl_len(cnt);
 }
-- 
1.7.10.4

