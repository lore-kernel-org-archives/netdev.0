From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/77] irda: convert ali driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:40 -0700
Message-ID: <20090321053713.525233490@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36560 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760809AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-ali.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/irda/ali-ircc.c |   23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

--- a/drivers/net/irda/ali-ircc.c	2009-03-19 22:40:30.305965477 -0700
+++ b/drivers/net/irda/ali-ircc.c	2009-03-19 22:42:49.992901415 -0700
@@ -259,6 +259,20 @@ static void __exit ali_ircc_cleanup(void
 	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 }
 
+static const struct net_device_ops ali_ircc_sir_ops = {
+	.ndo_open       = ali_ircc_net_open,
+	.ndo_stop       = ali_ircc_net_close,
+	.ndo_start_xmit = ali_ircc_sir_hard_xmit,
+	.ndo_do_ioctl   = ali_ircc_net_ioctl,
+};
+
+static const struct net_device_ops ali_ircc_fir_ops = {
+	.ndo_open       = ali_ircc_net_open,
+	.ndo_stop       = ali_ircc_net_close,
+	.ndo_start_xmit = ali_ircc_fir_hard_xmit,
+	.ndo_do_ioctl   = ali_ircc_net_ioctl,
+};
+
 /*
  * Function ali_ircc_open (int i, chipio_t *inf)
  *
@@ -361,10 +375,7 @@ static int ali_ircc_open(int i, chipio_t
 	self->tx_fifo.tail = self->tx_buff.head;
 
 	/* Override the network functions we need to use */
-	dev->hard_start_xmit = ali_ircc_sir_hard_xmit;
-	dev->open            = ali_ircc_net_open;
-	dev->stop            = ali_ircc_net_close;
-	dev->do_ioctl        = ali_ircc_net_ioctl;
+	dev->netdev_ops = &ali_ircc_sir_ops;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -974,7 +985,7 @@ static void ali_ircc_change_speed(struct
 		ali_ircc_fir_change_speed(self, baud);			
 		
 		/* Install FIR xmit handler*/
-		dev->hard_start_xmit = ali_ircc_fir_hard_xmit;		
+		dev->netdev_ops = &ali_ircc_fir_ops;
 				
 		/* Enable Interuupt */
 		self->ier = IER_EOM; // benjamin 2000/11/20 07:24PM					
@@ -988,7 +999,7 @@ static void ali_ircc_change_speed(struct
 		ali_ircc_sir_change_speed(self, baud);
 				
 		/* Install SIR xmit handler*/
-		dev->hard_start_xmit = ali_ircc_sir_hard_xmit;
+		dev->netdev_ops = &ali_ircc_sir_ops;
 	}
 	
 		

-- 

