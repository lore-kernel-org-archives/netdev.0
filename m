From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next] cnic: Add a signature to indicate valid doorbell offset.
Date: Tue, 31 Dec 2013 23:18:34 -0800
Message-ID: <1388560714-32561-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:51321 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaAAGyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:54:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

The buffer that is used to pass doorbell offset to the userspace UIO
driver may contain nonzero value in older versions of bnx2x driver.
Userspace cannot easily tell whether it contains a valid doorbell
offset or not.  With the added signature, userspace will only use
the doorbell offset if the signature is present.

Update version to 2.5.19.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |    1 +
 drivers/net/ethernet/broadcom/cnic.h    |    2 ++
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index f58a8b8..fcf9105 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5220,6 +5220,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		cnic_ring_ctl(dev, cid, cli, 1);
 		*cid_ptr = cid >> 4;
 		*(cid_ptr + 1) = cid * bp->db_size;
+		*(cid_ptr + 2) = UIO_USE_TX_DOORBELL;
 	}
 }
 
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 0121a5d..0d6b13f 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -186,6 +186,8 @@ struct kcq_info {
 	u16		(*hw_idx)(u16);
 };
 
+#define UIO_USE_TX_DOORBELL 0x017855DB
+
 struct cnic_uio_dev {
 	struct uio_info		cnic_uinfo;
 	u32			uio_dev;
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index ebbfe25..8cf6b19 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.18"
-#define CNIC_MODULE_RELDATE	"Sept 01, 2013"
+#define CNIC_MODULE_VERSION	"2.5.19"
+#define CNIC_MODULE_RELDATE	"December 19, 2013"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
