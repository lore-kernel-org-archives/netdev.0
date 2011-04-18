From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/42] atm: eni: Kill set-but-unused variables.
Date: Sun, 17 Apr 2011 17:32:36 -0700 (PDT)
Message-ID: <20110417.173236.226776260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40524
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611Ab1DRAdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:10 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 192E824C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable eni_dev is initialized but never subsequently used in
these two functions.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/eni.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index c495fae..3230ea0 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1469,10 +1469,7 @@ if (eni_boards) printk(KERN_INFO "loss: %ld\n",ENI_DEV(eni_boards)->lost);
 
 static void bug_int(struct atm_dev *dev,unsigned long reason)
 {
-	struct eni_dev *eni_dev;
-
 	DPRINTK(">bug_int\n");
-	eni_dev = ENI_DEV(dev);
 	if (reason & MID_DMA_ERR_ACK)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - DMA "
 		    "error\n",dev->number);
@@ -1900,7 +1897,6 @@ static void eni_close(struct atm_vcc *vcc)
 
 static int eni_open(struct atm_vcc *vcc)
 {
-	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
 	int error;
 	short vpi = vcc->vpi;
@@ -1910,7 +1906,6 @@ static int eni_open(struct atm_vcc *vcc)
 	EVENT("eni_open\n",0,0);
 	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags))
 		vcc->dev_data = NULL;
-	eni_dev = ENI_DEV(vcc->dev);
 	if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)
 		set_bit(ATM_VF_ADDR,&vcc->flags);
 	if (vcc->qos.aal != ATM_AAL0 && vcc->qos.aal != ATM_AAL5)
-- 
1.7.4.3

