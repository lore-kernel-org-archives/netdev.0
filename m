From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] cnic: Fix an error handling path in 'cnic_alloc_bnx2x_resc()'
Date: Fri, 22 Sep 2017 01:01:11 +0200
Message-ID: <20170921230111.10135-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: jmaxwell37@gmail.com, davem@davemloft.net,
        stephen@networkplumber.org, danielj@mellanox.com,
        parav@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the error handling paths 'goto error', except this one.
We should also go to error in this case, or some resources will be
leaking.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/broadcom/cnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index cec94bbb2ea5..8bc126a156e8 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1278,7 +1278,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 
 	ret = cnic_alloc_dma(dev, kwq_16_dma, pages, 0);
 	if (ret)
-		return -ENOMEM;
+		goto error;
 
 	n = CNIC_PAGE_SIZE / CNIC_KWQ16_DATA_SIZE;
 	for (i = 0, j = 0; i < cp->max_cid_space; i++) {
-- 
2.11.0
