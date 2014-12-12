From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net-next v10 2/7] cxgb4i: fix credit check for tx_data_wr
Date: Thu, 11 Dec 2014 19:13:32 -0800
Message-ID: <201412120313.sBC3DW59028334@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28330 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933854AbaLLDOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 22:14:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>

make sure any tx credit related checking is done before adding the wr header.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 8abe8a3..197d7de 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -549,10 +549,11 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 	struct fw_ofld_tx_data_wr *req;
 	unsigned int submode = cxgbi_skcb_ulp_mode(skb) & 3;
 	unsigned int wr_ulp_mode = 0, val;
+	bool imm = is_ofld_imm(skb);
 
 	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
 
-	if (is_ofld_imm(skb)) {
+	if (imm) {
 		req->op_to_immdlen = htonl(FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
 					FW_WR_COMPL_F |
 					FW_WR_IMMDLEN_V(dlen));
