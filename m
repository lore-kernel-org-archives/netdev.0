From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 17/26 v3] ib/sa: Export function to pack a path record into
 wire format
Date: Mon, 24 Sep 2012 23:55:34 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F122@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25822 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040Ab2IXXz5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:57 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow converting from struct ib_sa_path_rec to the IB defined
SA path record wire format.  This will be used to report path
data from the rdma cm into user space.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/sa_query.c |    6 ++++++
 include/rdma/ib_sa.h               |    6 ++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index fbbfa24..027c797 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -616,6 +616,12 @@ void ib_sa_unpack_path(void *attribute, struct ib_sa_path_rec *rec)
 }
 EXPORT_SYMBOL(ib_sa_unpack_path);
 
+void ib_sa_pack_path(struct ib_sa_path_rec *rec, void *attribute)
+{
+	ib_pack(path_rec_table, ARRAY_SIZE(path_rec_table), rec, attribute);
+}
+EXPORT_SYMBOL(ib_sa_pack_path);
+
 static void ib_sa_path_rec_callback(struct ib_sa_query *sa_query,
 				    int status,
 				    struct ib_sa_mad *mad)
diff --git a/include/rdma/ib_sa.h b/include/rdma/ib_sa.h
index d44a563..ade03ca 100644
--- a/include/rdma/ib_sa.h
+++ b/include/rdma/ib_sa.h
@@ -385,4 +385,10 @@ int ib_init_ah_from_path(struct ib_device *device, u8 port_num,
  */
 void ib_sa_unpack_path(void *attribute, struct ib_sa_path_rec *rec);
 
+/**
+ * ib_sa_pack_path - Conert a path record from struct ib_sa_path_rec
+ * to IB MAD wire format.
+ */
+void ib_sa_pack_path(struct ib_sa_path_rec *rec, void *attribute);
+
 #endif /* IB_SA_H */
