From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH v5 2/2] iWARP Core Changes.
Date: Wed, 30 Aug 2006 13:11:19 -0700
Message-ID: <ada7j0qm1aw.fsf@cisco.com>
References: <20060803210238.16228.47335.stgit@dell3.ogc.int>
	<20060803210242.16228.39306.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:35421 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1751448AbWH3ULW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 16:11:22 -0400
To: Steve Wise <swise@opengridcomputing.com>, tom@opengridcomputing.com
In-Reply-To: <20060803210242.16228.39306.stgit@dell3.ogc.int> (Steve Wise's message of "Thu, 03 Aug 2006 16:02:42 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While merging this, I uninlined rdma_node_get_transport, since I don't
think there's any reason to make it inline:

add/remove: 1/0 grow/shrink: 7/16 up/down: 65/-146 (-81)
function                                     old     new   delta
rdma_node_get_transport                        -      33     +33
rdma_init_qp_attr                             96     109     +13
rdma_resolve_route                           612     620      +8
cma_add_one                                  241     245      +4
rdma_create_qp                               302     305      +3
cma_rep_recv                                  94      96      +2
show_pkey                                    110     111      +1
rdma_reject                                  122     123      +1
rdma_accept                                  410     408      -2
cma_cleanup                                   52      50      -2
cma_acquire_dev                              181     179      -2
rdma_connect                                 767     764      -3
rdma_listen                                  831     825      -6
rdma_disconnect                              151     145      -6
ib_sa_add_one                                455     446      -9
ib_mad_init_device                          1393    1384      -9
ipoib_remove_one                             160     150     -10
ib_ucm_add_one                               377     365     -12
cma_destroy_listen                           196     184     -12
cma_cancel_operation                         258     246     -12
cm_add_one                                   446     434     -12
ipoib_add_one                                766     753     -13
ib_umad_add_one                              985     968     -17
rdma_destroy_id                              322     303     -19

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index 06f98e9..8b5dd36 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -79,6 +79,23 @@ enum ib_rate mult_to_ib_rate(int mult)
 }
 EXPORT_SYMBOL(mult_to_ib_rate);
 
+enum rdma_transport_type
+rdma_node_get_transport(enum rdma_node_type node_type)
+{
+	switch (node_type) {
+	case RDMA_NODE_IB_CA:
+	case RDMA_NODE_IB_SWITCH:
+	case RDMA_NODE_IB_ROUTER:
+		return RDMA_TRANSPORT_IB;
+	case RDMA_NODE_RNIC:
+		return RDMA_TRANSPORT_IWARP;
+	default:
+		BUG();
+		return 0;
+	}
+}
+EXPORT_SYMBOL(rdma_node_get_transport);
+
 /* Protection domains */
 
 struct ib_pd *ib_alloc_pd(struct ib_device *device)
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 91b7338..905b44e 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -69,21 +69,8 @@ enum rdma_transport_type {
 	RDMA_TRANSPORT_IWARP
 };
 
-static inline enum rdma_transport_type
-rdma_node_get_transport(enum rdma_node_type node_type)
-{
-	switch (node_type) {
-	case RDMA_NODE_IB_CA:
-	case RDMA_NODE_IB_SWITCH:
-	case RDMA_NODE_IB_ROUTER:
-		return RDMA_TRANSPORT_IB;
-	case RDMA_NODE_RNIC:
-		return RDMA_TRANSPORT_IWARP;
-	default:
-		BUG();
-		return 0;
-	}
-}
+enum rdma_transport_type
+rdma_node_get_transport(enum rdma_node_type node_type) __attribute_const__;
 
 enum ib_device_cap_flags {
 	IB_DEVICE_RESIZE_MAX_WR		= 1,
