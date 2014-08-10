From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] drivers: net: davinci_cpdma: drop devm_kfree of
 devm_kzalloc'd data
Date: Mon, 11 Aug 2014 01:28:19 +0530
Message-ID: <20140810195819.GA3880@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Daniel Mack <zonque@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Felipe Balbi <balbi@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

devm_kfree should not have to be explicitly used.

The Coccinelle semantic patch that fixes this problem is as follows:

// <smpl>
@@
expression x,d;
@@

x = devm_kzalloc(...)
...
?-devm_kfree(d,x);
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 4a000f6..af673f5 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -512,7 +512,6 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 	spin_lock_irqsave(&ctlr->lock, flags);
 	if (ctlr->channels[chan_num]) {
 		spin_unlock_irqrestore(&ctlr->lock, flags);
-		devm_kfree(ctlr->dev, chan);
 		return ERR_PTR(-EBUSY);
 	}
 
-- 
1.9.1
