From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH net v7 2/7] cxgb4i: fix credit check for tx_data_wr
Date: Wed, 10 Dec 2014 12:24:06 -0800
Message-ID: <201412102024.sBAKO6Xj011519@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24287 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821AbaLJUZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 15:25:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v7 2/7] cxgb4i: fix credit check for tx_data_wr

From: Karen Xie <kxie@chelsio.com>

make sure any tx credit related checking is done before adding the wr header.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index f119a67..abee611 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -547,10 +547,11 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 	struct fw_ofld_tx_data_wr *req;
 	unsigned int submode = cxgbi_skcb_ulp_mode(skb) & 3;
 	unsigned int wr_ulp_mode = 0;
+	bool imm = is_ofld_imm(skb);
 
 	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
 
-	if (is_ofld_imm(skb)) {
+	if (imm) {
 		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
 					FW_WR_COMPL(1) |
 					FW_WR_IMMDLEN(dlen));
