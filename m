From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/5] cnic: Allocate UIO resources only on
 devices that support iSCSI.
Date: Sat, 8 Sep 2012 09:01:05 -0700
Message-ID: <1347120065-26492-5-git-send-email-mchan@broadcom.com>
References: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
 <1347120065-26492-2-git-send-email-mchan@broadcom.com>
 <1347120065-26492-3-git-send-email-mchan@broadcom.com>
 <1347120065-26492-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3147 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab2IHPsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 11:48:21 -0400
In-Reply-To: <1347120065-26492-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update version to 2.5.13.

Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |    5 ++++-
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index c223314..2107d79 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1303,6 +1303,9 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
+	if (cp->ethdev->drv_state & CNIC_DRV_STATE_NO_ISCSI)
+		return 0;
+
 	cp->bnx2x_def_status_blk = cp->ethdev->irq_arr[1].status_blk;
 
 	cp->l2_rx_ring_size = 15;
@@ -5351,7 +5354,7 @@ static void cnic_stop_hw(struct cnic_dev *dev)
 		/* Need to wait for the ring shutdown event to complete
 		 * before clearing the CNIC_UP flag.
 		 */
-		while (cp->udev->uio_dev != -1 && i < 15) {
+		while (cp->udev && cp->udev->uio_dev != -1 && i < 15) {
 			msleep(100);
 			i++;
 		}
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 5cb8888..2e92c34 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.12"
-#define CNIC_MODULE_RELDATE	"June 29, 2012"
+#define CNIC_MODULE_VERSION	"2.5.13"
+#define CNIC_MODULE_RELDATE	"Sep 07, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
