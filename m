From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] ehea: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 05:46:11 +0200
Message-ID: <1378957571-3574-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/ibm/ehea/ehea_main.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 35853b4..04e0ef1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1285,7 +1285,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 
 	ret = ibmebus_request_irq(port->qp_eq->attr.ist1,
 				  ehea_qp_aff_irq_handler,
-				  IRQF_DISABLED, port->int_aff_name, port);
+				  0, port->int_aff_name, port);
 	if (ret) {
 		netdev_err(dev, "failed registering irq for qp_aff_irq_handler:ist=%X\n",
 			   port->qp_eq->attr.ist1);
@@ -1303,8 +1303,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 			 "%s-queue%d", dev->name, i);
 		ret = ibmebus_request_irq(pr->eq->attr.ist1,
 					  ehea_recv_irq_handler,
-					  IRQF_DISABLED, pr->int_send_name,
-					  pr);
+					  0, pr->int_send_name, pr);
 		if (ret) {
 			netdev_err(dev, "failed registering irq for ehea_queue port_res_nr:%d, ist=%X\n",
 				   i, pr->eq->attr.ist1);
@@ -3320,7 +3319,7 @@ static int ehea_probe_adapter(struct platform_device *dev)
 	}
 
 	ret = ibmebus_request_irq(adapter->neq->attr.ist1,
-				  ehea_interrupt_neq, IRQF_DISABLED,
+				  ehea_interrupt_neq, 0,
 				  "ehea_neq", adapter);
 	if (ret) {
 		dev_err(&dev->dev, "requesting NEQ IRQ failed\n");
-- 
1.8.1.2
