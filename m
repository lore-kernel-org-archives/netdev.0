From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 1/5] qede: Fix XDP memory leak on unload
Date: Tue, 9 May 2017 15:07:47 +0300
Message-ID: <1494331671-16273-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Suddarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0077.outbound.protection.outlook.com ([104.47.40.77]:12832
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753493AbdEIMIR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:08:17 -0400
In-Reply-To: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suddarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

When (re|un)loading, Tx-queues belonging to XDP would not get freed.

Fixes: cb6aeb079294 ("qede: Add support for XDP_TX")
Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index b9ba23d..263fd28 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1313,6 +1313,9 @@ static void qede_free_mem_fp(struct qede_dev *edev, struct qede_fastpath *fp)
 	if (fp->type & QEDE_FASTPATH_RX)
 		qede_free_mem_rxq(edev, fp->rxq);
 
+	if (fp->type & QEDE_FASTPATH_XDP)
+		qede_free_mem_txq(edev, fp->xdp_tx);
+
 	if (fp->type & QEDE_FASTPATH_TX)
 		qede_free_mem_txq(edev, fp->txq);
 }
-- 
1.9.3
