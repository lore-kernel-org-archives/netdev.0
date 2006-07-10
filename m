From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: [PATCH fixed] srp: fix fmr error handling
Date: Tue, 11 Jul 2006 01:10:11 +0300
Message-ID: <20060710221011.GA32328@mellanox.co.il>
References: <20060710193814.GA30521@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Hefty <sean.hefty@intel.com>,
	Roland Dreier <rolandd@cisco.com>, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v67.mxlogic.net ([208.65.145.67]:45277 "EHLO
	p02c11o144.mxlogic.net") by vger.kernel.org with ESMTP
	id S965298AbWGJWnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:43:53 -0400
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060710193814.GA30521@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, the last patch I sent was corrupted, here's an updated version:

---

commit 7289361d5f81463e4abb27334773750279547e8a
Author: Vu Pham <vu@mellanox.com>
Date:   Mon Jul 10 22:38:14 2006 +0300

    [PATCH] srp: fix fmr error handling
    
    srp_unmap_data assumes req->fmr is NULL if the request is not mapped,
    so we must clean it out in case of an error.
    
    Signed-off-by: Vu Pham <vu@mellanox.com>
    Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>
    Acked-by: Roland Dreier <rolandd@cisco.com>

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index 4e22afe..6191180 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -618,6 +618,7 @@ static int srp_map_fmr(struct srp_device
 					dma_pages, page_cnt, &io_addr);
 	if (IS_ERR(req->fmr)) {
 		ret = PTR_ERR(req->fmr);
+		req->fmr = NULL;
 		goto out;
 	}

-- 
MST
