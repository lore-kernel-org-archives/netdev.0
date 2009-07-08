From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 6/8 net-next-2.6] cxgb3: Fix mss table initialization
Date: Tue, 07 Jul 2009 22:48:59 -0700
Message-ID: <20090708054858.11344.86017.stgit@speedy5>
References: <20090708054832.11344.82449.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3106 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758473AbZGHFtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:49:01 -0400
In-Reply-To: <20090708054832.11344.82449.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Fix the HW SMT table initialization to avoid random
mss miscomputations for offload connections.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index ef59921..49fe46d 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -470,6 +470,7 @@ static int init_tp_parity(struct adapter *adap)
 		memset(req, 0, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SMT_WRITE_REQ, i));
+		req->mtu_idx = NMTUS - 1;
 		req->iff = i;
 		t3_mgmt_tx(adap, skb);
 		if (skb == adap->nofail_skb) {

