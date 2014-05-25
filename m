From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net] qlcnic: Initialize mailbox cmd structure to zero.
Date: Sun, 25 May 2014 10:55:02 -0400
Message-ID: <1401029702-22267-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:1239 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbaEYPYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 11:24:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Uninitialized fields in mailbox command structure
  caused commands to time out randomly due to garbage
  values, so initialize it to zero.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 6afe9c1..15f4c9e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -702,6 +702,7 @@ static int qlcnic_sriov_alloc_bc_mbx_args(struct qlcnic_cmd_args *mbx, u32 type)
 	const struct qlcnic_mailbox_metadata *mbx_tbl;
 	int i, size;
 
+	memset(mbx, 0, sizeof(*mbx));
 	mbx_tbl = qlcnic_sriov_bc_mbx_tbl;
 	size = ARRAY_SIZE(qlcnic_sriov_bc_mbx_tbl);
 
-- 
1.6.3.3
