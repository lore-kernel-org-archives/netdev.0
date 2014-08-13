From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 1/2] qlge: Fix compilation warning
Date: Wed, 13 Aug 2014 14:08:08 -0400
Message-ID: <1407953289-23460-2-git-send-email-harish.patil@qlogic.com>
References: <1407953289-23460-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37026 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbaHMSkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 14:40:37 -0400
In-Reply-To: <1407953289-23460-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

Fix the below warning message observed during qlge compilation:
qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b40050e..767bcc5 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1750,9 +1750,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 				       struct rx_ring *rx_ring,
 				       struct ib_mac_iocb_rsp *ib_mac_rsp)
 {
-	struct bq_desc *lbq_desc;
-	struct bq_desc *sbq_desc;
+	struct bq_desc *lbq_desc = NULL;
 	struct sk_buff *skb = NULL;
+	struct bq_desc *sbq_desc;
 	u32 length = le32_to_cpu(ib_mac_rsp->data_len);
 	u32 hdr_len = le32_to_cpu(ib_mac_rsp->hdr_len);
 	size_t hlen = ETH_HLEN;
-- 
1.8.1.4
