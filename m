From: Michael Wang <yun.wang@profitbricks.com>
Subject: [RFC PATCH 03/11] IB/Verbs: Use management helper has_mad() for mad-check
Date: Fri, 27 Mar 2015 16:43:09 +0100
Message-ID: <55157A8D.8080907@profitbricks.com>
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


Introduce helper has_mad() to help us check if an IB device support
Management Datagrams.

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/mad.c      |  4 ++--
 drivers/infiniband/core/user_mad.c |  2 +-
 include/rdma/ib_verbs.h            | 13 +++++++++++++
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index 23cf9e8..896b749 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -3057,7 +3057,7 @@ static void ib_mad_init_device(struct ib_device *device)
 {
     int start, end, i;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_mad(device))
         return;
 
     if (device->node_type == RDMA_NODE_IB_SWITCH) {
@@ -3102,7 +3102,7 @@ static void ib_mad_remove_device(struct ib_device *device)
 {
     int i, num_ports, cur_port;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_mad(device))
         return;
 
     if (device->node_type == RDMA_NODE_IB_SWITCH) {
diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 28a8b30..31feec3 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -1274,7 +1274,7 @@ static void ib_umad_add_one(struct ib_device *device)
     struct ib_umad_device *umad_dev;
     int s, e, i;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_mad(device))
         return;
 
     if (device->node_type == RDMA_NODE_IB_SWITCH)
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index ca6d6bc..7b2bfe8 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1783,6 +1783,19 @@ static inline int tech_iboe(struct ib_device *device, u8 port_num)
             rdma_port_ll_is_eth(device, port_num);
 }
 
+/**
+ * has_mad - Check if a device support Management Datagrams.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support
+ * Management Datagrams.
+ */
+static inline int has_mad(struct ib_device *device)
+{
+    return rdma_transport_is_ib(device);
+}
+
 int ib_query_gid(struct ib_device *device,
          u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
