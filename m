From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v5 7/7] libcxgbi: free skb after debug prints
Date: Tue, 09 Dec 2014 17:43:43 -0800
Message-ID: <201412100143.sBA1hhtl024948@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18115 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbaLJBo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 20:44:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v5 7/7] libcxgbi: free skb after debug prints

From: Karen Xie <kxie@chelsio.com>

The debug print was accessing the skb after it was freed.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/libcxgbi.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 7da59c3..eb58afc 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -2294,10 +2294,12 @@ int cxgbi_conn_xmit_pdu(struct iscsi_task *task)
 		return err;
 	}
 
-	kfree_skb(skb);
 	log_debug(1 << CXGBI_DBG_ISCSI | 1 << CXGBI_DBG_PDU_TX,
 		"itt 0x%x, skb 0x%p, len %u/%u, xmit err %d.\n",
 		task->itt, skb, skb->len, skb->data_len, err);
+
+	kfree_skb(skb);
+
 	iscsi_conn_printk(KERN_ERR, task->conn, "xmit err %d.\n", err);
 	iscsi_conn_failure(task->conn, ISCSI_ERR_XMIT_FAILED);
 	return err;
