From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH] qla3xxx: Ensure request/response queue addr writes to the
 registers
Date: Fri, 19 Oct 2012 09:22:29 +0800
Message-ID: <5080AB55.9010609@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080607040200060605000903"
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Greg Marsden <greg.marsden@oracle.com>
To: Ron Mercer <ron.mercer@qlogic.com>, Linux-Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080607040200060605000903
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Before use the request and response queue addr, make sure it has wrote
to the registers.

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index df09b1c..f745ade 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2525,6 +2525,12 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 	qdev->req_q_size =
 	    (u32) (NUM_REQ_Q_ENTRIES * sizeof(struct ob_mac_iocb_req));
 
+	/*
+	 * The barrier is required to ensure request and response queue
+	 * addr writes to the registers.
+	 */
+	wmb();
+
 	qdev->req_q_virt_addr =
 	    pci_alloc_consistent(qdev->pdev,
 				 (size_t) qdev->req_q_size,
-- 
1.7.11.7


--------------080607040200060605000903
Content-Type: text/plain; charset=us-ascii;
 name="Attached Message Part"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="Attached Message Part"


--------------080607040200060605000903--
