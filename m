From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v9 7/7] libcxgbi: fix freeing skb prematurely
Date: Thu, 11 Dec 2014 07:25:58 -0800
Message-ID: <201412111525.sBBFPw0b012963@localhost6.localdomain6>
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

From: Karen Xie <kxie@chelsio.com>

With debug turned on the debug print would access the skb after it is freed.
Fix it to free the skb after the debug print.

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
