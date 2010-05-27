From: Dan Carpenter <error27@gmail.com>
Subject: [patch 3/3] rds/iw_rdma: remove unneeded kfree()
Date: Thu, 27 May 2010 11:11:28 +0200
Message-ID: <20100527091128.GT22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44795 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933115Ab0E0JLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 05:11:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "dma_pages" variable is always NULL at this point so the kfree()
isn't needed.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 48d5073..742ab6a 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -334,7 +334,6 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
 out_unmap:
 	ib_dma_unmap_sg(rds_iwdev->dev, sg->list, sg->len, DMA_BIDIRECTIONAL);
 	sg->dma_len = 0;
-	kfree(dma_pages);
 	return ERR_PTR(ret);
 }
 
