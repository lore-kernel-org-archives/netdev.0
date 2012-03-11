From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 5/7] drivers/atm/eni.c: ensure arguments to request_irq and free_irq are compatible
Date: Sun, 11 Mar 2012 20:36:25 +0100
Message-ID: <1331494587-12196-6-git-send-email-Julia.Lawall@lip6.fr>
References: <1331494587-12196-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:50211 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534Ab2CKTgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Mar 2012 15:36:39 -0400
In-Reply-To: <1331494587-12196-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert call to request_irq so that the last argument is the same as the
second argument of the subsequent call to free_irq.  Without this
property, free_irq does nothing.

I have chosen to keep the call to free_irq as is, because its second
argument is more like its first argument.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.  I don't know if I have made the right choice.

 drivers/atm/eni.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 956e9ac..89e7223 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1800,7 +1800,8 @@ static int __devinit eni_start(struct atm_dev *dev)
 
 	DPRINTK(">eni_start\n");
 	eni_dev = ENI_DEV(dev);
-	if (request_irq(eni_dev->irq,&eni_int,IRQF_SHARED,DEV_LABEL,dev)) {
+	if (request_irq(eni_dev->irq, &eni_int, IRQF_SHARED, DEV_LABEL,
+			eni_dev)) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): IRQ%d is already in use\n",
 		    dev->number,eni_dev->irq);
 		error = -EAGAIN;
