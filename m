From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH rdma-next v1 02/12] IB/opa-vnic: RDMA NETDEV interface
Date: Tue, 11 Apr 2017 23:39:57 -0700
Message-ID: <1491979207-18686-3-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add rdma netdev interface to ib device structure allowing rdma netdev
devices to be allocated by ib clients.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/rdma/ib_verbs.h | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 3a8e058..1064459 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -55,6 +55,7 @@
 #include <net/ip.h>
 #include <linux/string.h>
 #include <linux/slab.h>
+#include <linux/netdevice.h>
 
 #include <linux/if_link.h>
 #include <linux/atomic.h>
@@ -1877,6 +1878,24 @@ struct ib_port_immutable {
 	u32                           max_mad_size;
 };
 
+/* rdma netdev type - specifies protocol type */
+enum rdma_netdev_t {
+	RDMA_NETDEV_OPA_VNIC
+};
+
+/**
+ * struct rdma_netdev - rdma netdev
+ * For cases where netstack interfacing is required.
+ */
+struct rdma_netdev {
+	void              *clnt_priv;
+	struct ib_device  *hca;
+	u8                 port_num;
+
+	/* control functions */
+	void (*set_id)(struct net_device *netdev, int id);
+};
+
 struct ib_device {
 	char                          name[IB_DEVICE_NAME_MAX];
 
@@ -2127,6 +2146,15 @@ struct ib_device {
 							   struct ib_rwq_ind_table_init_attr *init_attr,
 							   struct ib_udata *udata);
 	int                        (*destroy_rwq_ind_table)(struct ib_rwq_ind_table *wq_ind_table);
+	/* rdma netdev operations */
+	struct net_device *(*alloc_rdma_netdev)(
+					struct ib_device *device,
+					u8 port_num,
+					enum rdma_netdev_t type,
+					const char *name,
+					unsigned char name_assign_type,
+					void (*setup)(struct net_device *));
+	void (*free_rdma_netdev)(struct net_device *netdev);
 
 	struct module               *owner;
 	struct device                dev;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
