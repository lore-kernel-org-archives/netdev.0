From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: [PATCH] srp: fix fmr error handling
Date: Mon, 10 Jul 2006 22:38:14 +0300
Message-ID: <20060710193814.GA30521@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Hefty <sean.hefty@intel.com>,
	Roland Dreier <rolandd@cisco.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v65.mxlogic.net ([208.65.145.65]:58752 "EHLO
	p02c11o142.mxlogic.net") by vger.kernel.org with ESMTP
	id S1422799AbWGJThq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 15:37:46 -0400
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew, could you pls drop the following in -mm and on to Linus?

---

 From: Vu Pham <vu@mellanox.com>

srp_unmap_data assumes req->fmr is NULL if the request is not mapped,
so we must clean it out in case of an error.

Signed-off-by: Vu Pham <vu@mellanox.com>
Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>
Acked-by: Roland Dreier <rolandd@cisco.com>

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index 4e22afe..8f472e7 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -615,9 +615,10 @@ static int srp_map_fmr(struct srp_device
 				(sg_dma_address(&scat[i]) & dev->fmr_page_mask) + j;
 
 	req->fmr = ib_fmr_pool_map_phys(dev->fmr_pool,
					dma_pages, page_cnt, &io_addr);
 	if (IS_ERR(req->fmr)) {
 		ret = PTR_ERR(req->fmr);
+		req->fmr = NULL;
 		goto out;
 	}
 

-- 
MST

----- End forwarded message -----

-- 
MST
