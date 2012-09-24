From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 15/26 v3] rdma/cm: Only listen on IB devices when using AF_IB
Date: Mon, 24 Sep 2012 23:55:33 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F115@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31881 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab2IXXzh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:37 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an rdma_cm_id is bound to AF_IB, with a wild card address,
only listen on IB devices.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 13423bb..d7bc654 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1671,6 +1671,10 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 	struct rdma_cm_id *id;
 	int ret;
 
+	if (cma_family(id_priv) == AF_IB &&
+	    rdma_node_get_transport(cma_dev->device->node_type) != RDMA_TRANSPORT_IB)
+		return;
+
 	id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
 			    id_priv->id.qp_type);
 	if (IS_ERR(id))
