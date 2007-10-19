From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Eliminate pointless casts from void* in a few driver irq
	handlers.
Date: Fri, 19 Oct 2007 03:31:57 -0400
Message-ID: <20071019073157.GA5704@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46747 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763093AbXJSHb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 03:31:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 9739eb5090cc136ab50f2b323b83894c38d1ecb9
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Oct 19 03:10:11 2007 -0400

    Eliminate pointless casts from void* in a few driver irq handlers.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/atm/horizon.c              |    5 +++--
 drivers/char/tpm/tpm_tis.c         |    4 ++--
 drivers/mtd/onenand/onenand_base.c |    2 +-
 drivers/net/typhoon.c              |    2 +-
 drivers/net/ucc_geth.c             |    2 +-
 drivers/net/wan/sbni.c             |    4 ++--
 6 files changed, 10 insertions(+), 9 deletions(-)

9739eb5090cc136ab50f2b323b83894c38d1ecb9
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index f96446c..9b2cf25 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -1382,8 +1382,9 @@ static inline void rx_data_av_handler (hrz_dev * dev) {
 
 /********** interrupt handler **********/
 
-static irqreturn_t interrupt_handler(int irq, void *dev_id) {
-  hrz_dev * dev = (hrz_dev *) dev_id;
+static irqreturn_t interrupt_handler(int irq, void *dev_id)
+{
+  hrz_dev *dev = dev_id;
   u32 int_source;
   unsigned int irq_ok;
   
diff --git a/drivers/char/tpm/tpm_tis.c b/drivers/char/tpm/tpm_tis.c
index a8e8084..fd771a4 100644
--- a/drivers/char/tpm/tpm_tis.c
+++ b/drivers/char/tpm/tpm_tis.c
@@ -381,7 +381,7 @@ static struct tpm_vendor_specific tpm_tis = {
 
 static irqreturn_t tis_int_probe(int irq, void *dev_id)
 {
-	struct tpm_chip *chip = (struct tpm_chip *) dev_id;
+	struct tpm_chip *chip = dev_id;
 	u32 interrupt;
 
 	interrupt = ioread32(chip->vendor.iobase +
@@ -401,7 +401,7 @@ static irqreturn_t tis_int_probe(int irq, void *dev_id)
 
 static irqreturn_t tis_int_handler(int irq, void *dev_id)
 {
-	struct tpm_chip *chip = (struct tpm_chip *) dev_id;
+	struct tpm_chip *chip = dev_id;
 	u32 interrupt;
 	int i;
 
diff --git a/drivers/mtd/onenand/onenand_base.c b/drivers/mtd/onenand/onenand_base.c
index dd28355..1b0b320 100644
--- a/drivers/mtd/onenand/onenand_base.c
+++ b/drivers/mtd/onenand/onenand_base.c
@@ -359,7 +359,7 @@ static int onenand_wait(struct mtd_info *mtd, int state)
  */
 static irqreturn_t onenand_interrupt(int irq, void *data)
 {
-	struct onenand_chip *this = (struct onenand_chip *) data;
+	struct onenand_chip *this = data;
 
 	/* To handle shared interrupt */
 	if (!this->complete.done)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 72e5e9b..94ac586 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1801,7 +1801,7 @@ typhoon_poll(struct napi_struct *napi, int budget)
 static irqreturn_t
 typhoon_interrupt(int irq, void *dev_instance)
 {
-	struct net_device *dev = (struct net_device *) dev_instance;
+	struct net_device *dev = dev_instance;
 	struct typhoon *tp = dev->priv;
 	void __iomem *ioaddr = tp->ioaddr;
 	u32 intr_status;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index bec413b..9741d61 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3607,7 +3607,7 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 
 static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 {
-	struct net_device *dev = (struct net_device *)info;
+	struct net_device *dev = info;
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	struct ucc_fast_private *uccf;
 	struct ucc_geth_info *ug_info;
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 76db40d..2e8b5c2 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -502,8 +502,8 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 static irqreturn_t
 sbni_interrupt( int  irq,  void  *dev_id )
 {
-	struct net_device	  *dev = (struct net_device *) dev_id;
-	struct net_local  *nl  = (struct net_local *) dev->priv;
+	struct net_device	  *dev = dev_id;
+	struct net_local  *nl  = dev->priv;
 	int	repeat;
 
 	spin_lock( &nl->lock );
