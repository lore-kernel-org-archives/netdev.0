From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v4 7/7] libcxgbi: free skb after debug prints
Date: Tue, 09 Dec 2014 17:33:12 -0800
Message-ID: <201412100133.sBA1XC3P024855@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH net v4 7/7] libcxgbi: free skb after debug prints

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
