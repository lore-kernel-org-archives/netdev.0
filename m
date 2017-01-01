From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 11/12] qed: Conserve RDMA resources when !QEDR
Date: Sun, 1 Jan 2017 13:57:10 +0200
Message-ID: <1483271831-25890-12-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@Cavium.com>,
        Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51486 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932205AbdAAL6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:36 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@Cavium.com>

If qedr isn't part of the kernel then don't allocate RDMA resources
for it in qed.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 2566741..5d026db 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1122,7 +1122,9 @@ int qed_mcp_get_media_type(struct qed_dev *cdev, u32 *p_media_type)
 
 	switch (p_info->config & FUNC_MF_CFG_PROTOCOL_MASK) {
 	case FUNC_MF_CFG_PROTOCOL_ETHERNET:
-		if (qed_mcp_get_shmem_proto_mfw(p_hwfn, p_ptt, p_proto))
+		if (!IS_ENABLED(CONFIG_QED_RDMA))
+			*p_proto = QED_PCI_ETH;
+		else if (qed_mcp_get_shmem_proto_mfw(p_hwfn, p_ptt, p_proto))
 			qed_mcp_get_shmem_proto_legacy(p_hwfn, p_proto);
 		break;
 	case FUNC_MF_CFG_PROTOCOL_ISCSI:
-- 
1.9.3
