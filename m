From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH] qla3xxx: Ensure request/response queue addr writes to
 the registers
Date: Mon, 22 Oct 2012 10:17:14 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA87744C0B09B@AVEXMB1.qlogic.org>
References: <50849604.9050109@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Greg Marsden <greg.marsden@oracle.com>
To: Joe Jin <joe.jin@oracle.com>, Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50849604.9050109@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



>From: Joe Jin [mailto:joe.jin@oracle.com] 
>Sent: Sunday, October 21, 2012 5:41 PM
>To: Jitendra Kalsaria; Ron Mercer; Dept-Eng Linux Driver; David Miller; Andrew Morton
>Cc: netdev; linux-kernel; Greg Marsden
>Subject: [PATCH] qla3xxx: Ensure request/response queue addr writes to the registers
>
>Before use the request and response queue addr, make sure it has wrote
>to the registers.
>
>Signed-off-by: Joe Jin <joe.jin@oracle.com>
>Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>Cc: Ron Mercer <ron.mercer@qlogic.com>
>---
> drivers/net/ethernet/qlogic/qla3xxx.c | 9 +++++++--
> 1 file changed, 7 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
>index df09b1c..6407d0d 100644
>--- a/drivers/net/ethernet/qlogic/qla3xxx.c
>+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
>@@ -2525,6 +2525,13 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
> 	qdev->req_q_size =
> 	    (u32) (NUM_REQ_Q_ENTRIES * sizeof(struct ob_mac_iocb_req));
> 
>+	qdev->rsp_q_size = NUM_RSP_Q_ENTRIES * sizeof(struct net_rsp_iocb);
>+
>+	/* The barrier is required to ensure request and response queue
>+	 * addr writes to the registers.
>+	 */
>+	wmb();
>+
> 	qdev->req_q_virt_addr =
> 	    pci_alloc_consistent(qdev->pdev,
> 				 (size_t) qdev->req_q_size,
>@@ -2536,8 +2543,6 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
> 		return -ENOMEM;
> 	}
> 
>-	qdev->rsp_q_size = NUM_RSP_Q_ENTRIES * sizeof(struct net_rsp_iocb);
>-
> 	qdev->rsp_q_virt_addr =
> 	    pci_alloc_consistent(qdev->pdev,
> 				 (size_t) qdev->rsp_q_size,

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

-- 
1.7.11.7
