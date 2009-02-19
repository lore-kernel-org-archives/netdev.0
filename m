From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 5/7] fcoe: add support to net_fcoe_ops in fcoe_sw
Date: Thu, 19 Feb 2009 12:50:14 -0700
Message-ID: <20090219195014.22270.66568.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34251 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755012AbZBSU5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 15:57:22 -0500
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds implementation of ddp_setup()/ddp_done() in fcoe_sw for its
fcoe_sw_libfc_fcn_templ.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/fcoe_sw.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe_sw.c b/drivers/scsi/fcoe/fcoe_sw.c
index 7632d7e..57f7a51 100644
--- a/drivers/scsi/fcoe/fcoe_sw.c
+++ b/drivers/scsi/fcoe/fcoe_sw.c
@@ -373,8 +373,45 @@ static int fcoe_sw_destroy(struct net_device *netdev)
 	return 0;
 }
 
+/*
+ * fcoe_sw_ddp_setup - calls LLD's ddp_setup through net_device
+ * @lp:	the corresponding fc_lport
+ * @xid: the exchange id for this ddp transfer
+ * @sgl: the scatterlist describing this transfer
+ * @sgc: number of sg items
+ *
+ * Returns : 0 no ddp
+ */
+static int fcoe_sw_ddp_setup(struct fc_lport *lp, u16 xid,
+			     struct scatterlist *sgl, unsigned int sgc)
+{
+	struct net_device *ndev = fcoe_netdev(lp);
+
+	if (ndev->fcoe_ops && ndev->fcoe_ops->ddp_setup)
+		return ndev->fcoe_ops->ddp_setup(ndev, xid, sgl, sgc);
+	return 0;
+}
+
+/*
+ * fcoe_sw_ddp_done - calls LLD's ddp_done through net_device
+ * @lp:	the corresponding fc_lport
+ * @xid: the exchange id for this ddp transfer
+ *
+ * Returns : the length of data that have been completed by ddp
+ */
+static int fcoe_sw_ddp_done(struct fc_lport *lp, u16 xid)
+{
+	struct net_device *ndev = fcoe_netdev(lp);
+
+	if (ndev->fcoe_ops && ndev->fcoe_ops->ddp_done)
+		return ndev->fcoe_ops->ddp_done(ndev, xid);
+	return 0;
+}
+
 static struct libfc_function_template fcoe_sw_libfc_fcn_templ = {
 	.frame_send = fcoe_xmit,
+	.ddp_setup = fcoe_sw_ddp_setup,
+	.ddp_done = fcoe_sw_ddp_done,
 };
 
 /**

