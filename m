From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: [PATCH] IB/cm: set private data length for reject messages
Date: Tue, 11 Jul 2006 01:43:42 +0300
Message-ID: <20060710224342.GA496@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Hefty <sean.hefty@intel.com>,
	Roland Dreier <rolandd@cisco.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v69.mxlogic.net ([208.65.145.69]:52356 "EHLO
	p02c11o146.mxlogic.net") by vger.kernel.org with ESMTP
	id S965296AbWGJWn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:43:27 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,
Here's another infiniband patch that needs to go upstream.

---

From: "Ira Weiny" <weiny2@llnl.gov>

Set private data length for reject messages to the correct size.
Fix from openib svn r8483.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>

Index: openib/drivers/infiniband/core/cma.c
===================================================================
--- openib/drivers/infiniband/core/cma.c	(revision 8482)
+++ openib/drivers/infiniband/core/cma.c	(revision 8483)
@@ -906,6 +906,7 @@ static int cma_ib_handler(struct ib_cm_i
 		cma_modify_qp_err(&id_priv->id);
 		status = ib_event->param.rej_rcvd.reason;
 		event = RDMA_CM_EVENT_REJECTED;
+		private_data_len = IB_CM_REJ_PRIVATE_DATA_SIZE;
 		break;
 	default:
 		printk(KERN_ERR "RDMA CMA: unexpected IB CM event: %d",

-- 
MST
