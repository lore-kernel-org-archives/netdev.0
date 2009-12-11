From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2] cnic: Send delete command when shutting down iSCSI
 ring.
Date: Thu, 10 Dec 2009 17:40:57 -0800
Message-ID: <1260495658-25866-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4108 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762111AbZLKBdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 20:33:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This step is necessary on the bnx2x devices when restarting the iSCSI
ring.  Without it, the firmware can assert and cause bnx2x to report
errors.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index d4c6e7f..a2c3328 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4183,6 +4183,12 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_HALT,
 			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
 		msleep(10);
+
+		memset(&l5_data, 0, sizeof(l5_data));
+		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CFC_DEL,
+			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE |
+			(1 << SPE_HDR_COMMON_RAMROD_SHIFT), &l5_data);
+		msleep(10);
 	}
 }
 
-- 
1.6.4.GIT


