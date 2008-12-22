From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.29] cxgb3 - add control to access embedded images
Date: Mon, 22 Dec 2008 12:55:01 -0800
Message-ID: <20081222205500.12971.4243.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:17825 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbYLVUzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 15:55:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Update contol path between cxgb3 and ULP modules (iWARP, iSCSI)
to provide access to firware and protocol engine info.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_ctl_defs.h |   10 ++++++++++
 drivers/net/cxgb3/cxgb3_offload.c  |    9 +++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 55099eb..369fe71 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -58,6 +58,8 @@ enum {
 
 	GET_RX_PAGE_INFO	= 50,
 	GET_ISCSI_IPV4ADDR	= 51,
+
+	GET_EMBEDDED_INFO	= 70,
 };
 
 /*
@@ -176,4 +178,12 @@ struct ofld_page_info {
 	unsigned int page_size;  /* Page size, should be a power of 2 */
 	unsigned int num;        /* Number of pages */
 };
+
+/*
+ * Structure used to get firmware and protocol engine versions.
+ */
+struct ch_embedded_info {
+	u32 fw_vers;
+	u32 tp_vers;
+};
 #endif				/* _CXGB3_OFFLOAD_CTL_DEFS_H */
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 1ce69b7..2d7f69a 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -438,6 +438,15 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 		p->ipv4addr = pi->iscsi_ipv4addr;
 		break;
 	}
+	case GET_EMBEDDED_INFO: {
+		struct ch_embedded_info *e = data;
+
+		spin_lock(&adapter->stats_lock);
+		t3_get_fw_version(adapter, &e->fw_vers);
+		t3_get_tp_version(adapter, &e->tp_vers);
+		spin_unlock(&adapter->stats_lock);
+		break;
+	}
 	default:
 		return -EOPNOTSUPP;
 	}

