From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH 1/3] qla3xxx: ethernet: Fix bogus interrupt state flag.
Date: Fri, 2 Mar 2012 10:51:42 -0800
Message-ID: <5E4F49720D0BAD499EE1F01232234BA8743804E40F@AVEXMB1.qlogic.org>
References: <1330700945-18195-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330700945-18195-1-git-send-email-santoshprasadnayak@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will review your patch and get back to you.

-----Original Message-----
From: santosh nayak [mailto:santoshprasadnayak@gmail.com] 
Sent: Friday, March 02, 2012 7:09 AM
To: Jitendra Kalsaria
Cc: Ron Mercer; Dept-Eng Linux Driver; netdev; linux-kernel; kernel-janitors@vger.kernel.org; Santosh Nayak
Subject: [PATCH 1/3] qla3xxx: ethernet: Fix bogus interrupt state flag.

From: Santosh Nayak <santoshprasadnayak@gmail.com>

In 'ql_adapter_initialize'
the first call for 'spin_unlock_irqrestore()' is with hw_flags = 0,
which is as good as 'spin_unlock_irq()' (unconditional interrupt
enabling). If this is intended, then for better performance
'spin_unlock_irqrestore()' can be replaced with 'spin_unlock_irq()'
and 'spin_lock_irqsave()' can be replaced by 'spin_lock_irq()

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index d49f6da..8da3e41 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3017,7 +3017,6 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 		(void __iomem *)port_regs;
 	u32 delay = 10;
 	int status = 0;
-	unsigned long hw_flags = 0;
 
 	if (ql_mii_setup(qdev))
 		return -1;
@@ -3228,9 +3227,9 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 		value = ql_read_page0_reg(qdev, &port_regs->portStatus);
 		if (value & PORT_STATUS_IC)
 			break;
-		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+		spin_unlock_irq(&qdev->hw_lock);
 		msleep(500);
-		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+		spin_lock_irq(&qdev->hw_lock);
 	} while (--delay);
 
 	if (delay == 0) {
-- 
1.7.4.4
