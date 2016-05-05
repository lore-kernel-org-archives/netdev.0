From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qede: uninitialized variable in qede_start_xmit()
Date: Thu, 5 May 2016 16:21:30 +0300
Message-ID: <20160505132130.GE3038@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@qlogic.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"data_split" was never set to false.  It's just uninitialized.

Fixes: 2950219d87b0 ('qede: Add basic network device support')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 60a61c3..d98f35e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -429,7 +429,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	u8 xmit_type;
 	u16 idx;
 	u16 hlen;
-	bool data_split;
+	bool data_split = false;
 
 	/* Get tx-queue context and netdev index */
 	txq_index = skb_get_queue_mapping(skb);
