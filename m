From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2] cnic: Zero out status block and Event Queue
 indices.
Date: Thu, 10 Dec 2009 17:40:58 -0800
Message-ID: <1260495658-25866-2-git-send-email-mchan@broadcom.com>
References: <1260495658-25866-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4107 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762156AbZLKBdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 20:33:35 -0500
In-Reply-To: <1260495658-25866-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent stale indices from causing spurious events when restarting the
bnx2x devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index a2c3328..4332b3a 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1104,6 +1104,8 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	cp->bnx2x_status_blk = cp->status_blk;
 	cp->bnx2x_def_status_blk = cp->ethdev->irq_arr[1].status_blk;
 
+	memset(cp->bnx2x_status_blk, 0, sizeof(struct host_status_block));
+
 	cp->l2_rx_ring_size = 15;
 
 	ret = cnic_alloc_l2_rings(dev, 4);
@@ -4295,6 +4297,9 @@ static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 		  offsetof(struct cstorm_status_block_c,
 			   index_values[HC_INDEX_C_ISCSI_EQ_CONS]),
 		  0);
+	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->func, 0), 0);
+	CNIC_WR16(dev, cp->kcq_io_addr, 0);
 	cnic_free_resc(dev);
 }
 
-- 
1.6.4.GIT


