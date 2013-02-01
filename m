From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Fri, 1 Feb 2013 16:56:26 +0800
Message-ID: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:26339
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756098Ab3BAJeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 04:34:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BUG: spinlock bad magic on CPU#1, swapper/0/1
lock: 0xbfae0f8c, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
Backtrace:
 [<80011d54>] (dump_backtrace+0x0/0x10c) from [<804e7800>] (dump_stack+0x18/0x1c)
 r6:bfae0000 r5:bfae0f8c r4:00000000 r3:806c1310
 [<804e77e8>] (dump_stack+0x0/0x1c) from [<804e9f20>] (spin_dump+0x80/0x94)
 [<804e9ea0>] (spin_dump+0x0/0x94) from [<804e9f60>] (spin_bug+0x2c/0x30)
 r5:805f6f8c r4:bfae0f8c
 [<804e9f34>] (spin_bug+0x0/0x30) from [<80257984>] (do_raw_spin_lock+0x170/0x1b0                                         )
 r5:806b4950 r4:bfae0f8c
 [<80257814>] (do_raw_spin_lock+0x0/0x1b0) from [<804ed15c>] (_raw_spin_lock_irqs                                         ave+0x18/0x20)
 [<804ed144>] (_raw_spin_lock_irqsave+0x0/0x20) from [<8033c694>] (fec_ptp_start_                                         cyclecounter+0x3c/0x120)
 r4:bfae0f8c r3:00000002
 [<8033c658>] (fec_ptp_start_cyclecounter+0x0/0x120) from [<80339e08>] (fec_resta                                         rt+0x56c/0x5f8)
 r8:00000000 r7:806e6f48 r6:00000112 r5:806b4950 r4:bfae0000
 [<8033989c>] (fec_restart+0x0/0x5f8) from [<8033b9e4>] (fec_probe+0x508/0xa48)

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 69b16b9..f900ae4 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1607,6 +1607,7 @@ static int fec_enet_init(struct net_device *ndev)
 	}
 
 	spin_lock_init(&fep->hw_lock);
+	spin_lock_init(&fep->tmreg_lock);
 
 	fep->netdev = ndev;
 
-- 
1.7.1
