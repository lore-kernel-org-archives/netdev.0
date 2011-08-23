From: Abhilash K V <abhilash.kv@ti.com>
Subject: [PATCH] can: ti_hecc: Fix uninitialized spinlock in probe
Date: Tue, 23 Aug 2011 18:35:57 +0530
Message-ID: <1314104757-16462-1-git-send-email-abhilash.kv@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wg@grandegger.com>, <linux-kernel@vger.kernel.org>,
	<=linux-omap@vger.kernel.org>, Abhilash K V <abhilash.kv@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:50021 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab1HWNGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 09:06:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ti_hecc_probe(), the spinlock  priv->mbx_lock is not
inited, causing a spinlock lockup BUG.

Acked-by: Anant Gole <anantgole@ti.com>
Signed-off-by: Abhilash K V <abhilash.kv@ti.com>
---
 drivers/net/can/ti_hecc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 0b19a17..a812492 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -923,6 +923,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	priv->can.do_get_state = ti_hecc_get_state;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
+	spin_lock_init(&priv->mbx_lock);
 	ndev->irq = irq->start;
 	ndev->flags |= IFF_ECHO;
 	platform_set_drvdata(pdev, ndev);
-- 
1.6.2.4

