From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 1/2] qlge: Fix compilation warning
Date: Thu, 18 Sep 2014 17:27:24 -0400
Message-ID: <1411075645-21845-2-git-send-email-harish.patil@qlogic.com>
References: <1411075645-21845-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:11298 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757218AbaIRWBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 18:01:10 -0400
In-Reply-To: <1411075645-21845-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

Signed-off-by: Harish Patil <harish.patil@qlogic.com>

Fix the below warning message:
qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 3e96f26..6c904a6 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1922,7 +1922,7 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			sbq_desc->p.skb = NULL;
 			skb_reserve(skb, NET_IP_ALIGN);
 		}
-		while (length > 0) {
+		do {
 			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
 			size = (length < rx_ring->lbq_buf_size) ? length :
 				rx_ring->lbq_buf_size;
@@ -1939,7 +1939,7 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			skb->truesize += size;
 			length -= size;
 			i++;
-		}
+		} while (length > 0);
 		ql_update_mac_hdr_len(qdev, ib_mac_rsp, lbq_desc->p.pg_chunk.va,
 				      &hlen);
 		__pskb_pull_tail(skb, hlen);
-- 
1.8.1.4
