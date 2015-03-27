From: Michael Wang <yun.wang@profitbricks.com>
Subject: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp() for,
 iwarp-check
Date: Fri, 27 Mar 2015 16:47:36 +0100
Message-ID: <55157B98.1060103@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
	Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bart Van Assche <bvanassche@acm.org>,
	Yann Droneaud <ydroneaud@opteya.com>,
	Colin Ian King <colin.king@canonical.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Matan Barak <matanb@mellanox.com>,
	Alex Estrin <alex.estrin@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Erez Shitrit <erezsh@mellanox.com>,
	Sagi Grimberg <sagig@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Mike Marciniszyn <mike.m
To: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551579CA.4030901@profitbricks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Introduce helper has_iwarp() to help us check if an IB device
support IWARP protocol.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 include/rdma/ib_verbs.h                 | 13 +++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |  2 +-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index e796104..0ef9cd7 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1836,6 +1836,19 @@ static inline int has_mcast(struct ib_device *device)
 }
 
 /**
+ * has_iwarp - Check if a device support IWARP protocol.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support
+ * IWARP protocol.
+ */
+static inline int has_iwarp(struct ib_device *device)
+{
+    return rdma_transport_is_iwarp(device);
+}
+
+/**
  * cap_smi - Check if the port of device has the capability
  * Subnet Management Interface.
  *
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index a7b5891..48aeb5e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -118,7 +118,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 
 static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
 {
-    if (rdma_transport_is_iwarp(xprt->sc_cm_id->device))
+    if (has_iwarp(xprt->sc_cm_id->device))
         return 1;
     else
         return min_t(int, sge_count, xprt->sc_max_sge);
-- 
2.1.0
