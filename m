From: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 09/10] nfc: nci: add nci_get_conn_info_by_id function
Date: Thu, 22 Oct 2015 12:11:41 +0300
Message-ID: <1445505102-16639-10-git-send-email-robert.dolca@intel.com>
References: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Robert Dolca <robert.dolca-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445505102-16639-1-git-send-email-robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This functin takes as a parameter a pointer to the nci_dev struct and
the first byte from the values of the first domain specific parameter that
was used for the connection creation.

Signed-off-by: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/core.c         | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 5daf004..0569cb2 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -374,6 +374,7 @@ void nci_clear_target_list(struct nci_dev *ndev);
 void nci_req_complete(struct nci_dev *ndev, int result);
 struct nci_conn_info *nci_get_conn_info_by_conn_id(struct nci_dev *ndev,
 						   int conn_id);
+int nci_get_conn_info_by_id(struct nci_dev *ndev, u8 id);
 
 /* ----- NCI status code ----- */
 int nci_to_errno(__u8 code);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 9d5f7a2..75bda34 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -64,6 +64,19 @@ struct nci_conn_info *nci_get_conn_info_by_conn_id(struct nci_dev *ndev,
 	return NULL;
 }
 
+int nci_get_conn_info_by_id(struct nci_dev *ndev, u8 id)
+{
+	struct nci_conn_info *conn_info;
+
+	list_for_each_entry(conn_info, &ndev->conn_info_list, list) {
+		if (conn_info->id == id)
+			return conn_info->conn_id;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(nci_get_conn_info_by_id);
+
 /* ---- NCI requests ---- */
 
 void nci_req_complete(struct nci_dev *ndev, int result)
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
