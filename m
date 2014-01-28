From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 1/4] qlcnic: Correct off-by-one errors in bounds checks
Date: Tue, 28 Jan 2014 11:55:27 -0500
Message-ID: <1390928130-10710-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46634 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755182AbaA1RaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:30:05 -0500
In-Reply-To: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Bound checks should be >= instead of > for number of receive descriptors
  and number of receive rings.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 30874cd..19e1a93 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1150,13 +1150,13 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	u16 lro_length, length, data_offset, t_vid, vid = 0xffff;
 	u32 seq_number;
 
-	if (unlikely(ring > adapter->max_rds_rings))
+	if (unlikely(ring >= adapter->max_rds_rings))
 		return NULL;
 
 	rds_ring = &recv_ctx->rds_rings[ring];
 
 	index = qlcnic_get_lro_sts_refhandle(sts_data0);
-	if (unlikely(index > rds_ring->num_desc))
+	if (unlikely(index >= rds_ring->num_desc))
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
@@ -1662,13 +1662,13 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	u16 vid = 0xffff;
 	int err;
 
-	if (unlikely(ring > adapter->max_rds_rings))
+	if (unlikely(ring >= adapter->max_rds_rings))
 		return NULL;
 
 	rds_ring = &recv_ctx->rds_rings[ring];
 
 	index = qlcnic_83xx_hndl(sts_data[0]);
-	if (unlikely(index > rds_ring->num_desc))
+	if (unlikely(index >= rds_ring->num_desc))
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
-- 
1.5.6
