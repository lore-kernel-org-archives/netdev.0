From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 20/28] ib/sa: Export function to pack a path record into wire format
Date: Wed, 29 May 2013 10:09:26 -0700
Message-ID: <1369847374-12176-21-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Allow converting from struct ib_sa_path_rec to the IB defined
SA path record wire format.  This will be used to report path
data from the rdma cm into user space.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/sa_query.c |    6 ++++++
 include/rdma/ib_sa.h               |    7 +++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 934f45e..9838ca4 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -652,6 +652,12 @@ void ib_sa_unpack_path(void *attribute, struct ib_sa_path_rec *rec)
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
index 8275e53..125f871 100644
--- a/include/rdma/ib_sa.h
+++ b/include/rdma/ib_sa.h
@@ -402,6 +402,12 @@ int ib_init_ah_from_path(struct ib_device *device, u8 port_num,
 			 struct ib_ah_attr *ah_attr);
 
 /**
+ * ib_sa_pack_path - Conert a path record from struct ib_sa_path_rec
+ * to IB MAD wire format.
+ */
+void ib_sa_pack_path(struct ib_sa_path_rec *rec, void *attribute);
+
+/**
  * ib_sa_unpack_path - Convert a path record from MAD format to struct
  * ib_sa_path_rec.
  */
@@ -418,4 +424,5 @@ int ib_sa_guid_info_rec_query(struct ib_sa_client *client,
 					       void *context),
 			      void *context,
 			      struct ib_sa_query **sa_query);
+
 #endif /* IB_SA_H */
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
