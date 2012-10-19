From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH] qla3xxx: Ensure request/response queue addr writes to
 the registers
Date: Fri, 19 Oct 2012 10:12:25 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA87744A9406C@AVEXMB1.qlogic.org>
References: <5080ABD7.90006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Greg Marsden <greg.marsden@oracle.com>
To: Joe Jin <joe.jin@oracle.com>, Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5080ABD7.90006@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



>From: Joe Jin [mailto:joe.jin@oracle.com] 
>Sent: Thursday, October 18, 2012 6:25 PM
>To: Ron Mercer; Dept-Eng Linux Driver; Jitendra Kalsaria; Joe Jin
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
> drivers/net/ethernet/qlogic/qla3xxx.c | 6 ++++++
> 1 file changed, 6 insertions(+)
>
>diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
>index df09b1c..f745ade 100644
>--- a/drivers/net/ethernet/qlogic/qla3xxx.c
>+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
>@@ -2525,6 +2525,12 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
> 	qdev->req_q_size =
> 	    (u32) (NUM_REQ_Q_ENTRIES * sizeof(struct ob_mac_iocb_req));
> 
>+	/*
>+	 * The barrier is required to ensure request and response queue
>+	 * addr writes to the registers.
>+	 */
>+	wmb();
>+
> 	qdev->req_q_virt_addr =
> 	    pci_alloc_consistent(qdev->pdev,
> 				 (size_t) qdev->req_q_size,

Joe,

You need to move below line above the write memory barrier to get response queue address write to register
	qdev->rsp_q_size = NUM_RSP_Q_ENTRIES * sizeof(struct net_rsp_iocb);

Your patch will be like below:
<snip>
	qdev->req_q_size =
		(u32) (NUM_REQ_Q_ENTRIES * sizeof(struct ob_mac_iocb_req));

+	qdev->rsp_q_size = NUM_RSP_Q_ENTRIES * sizeof(struct net_rsp_iocb);
+
+	/*
+	 * The barrier is required to ensure request and response queue
+	 * addr writes to the registers.
+	 */
+	wmb();
+

<\snip>


thanks,
	Jiten
-- 
1.7.11.7
