From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/3][ATM]: kmalloc to kzalloc patches for drivers/atm
Date: Sun, 01 Oct 2006 11:17:05 -0400
Message-ID: <200610011517.k91FH5Tv006371@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:43409 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1750952AbWJAPRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 11:17:22 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: kmalloc to kzalloc patches for drivers/atm

Signed-off-by: Om Narasimhan <om.turyx@gmail.com>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 339d365266211690a446773e3eb9d864637a71bb
tree d48530e7ba716797687d2831f0f5148cda4a999a
parent f69365e8b58c325546d2e090c9019737436e0712
author Om Narasimhan <om.turyx@gmail.com> Sat, 30 Sep 2006 22:00:22 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 30 Sep 2006 22:00:22 -0400

 drivers/atm/adummy.c     |    6 ++----
 drivers/atm/firestream.c |   12 +++---------
 drivers/atm/he.c         |    4 +---
 drivers/atm/horizon.c    |    4 +---
 drivers/atm/idt77252.c   |   23 ++++++-----------------
 drivers/atm/lanai.c      |    8 +-------
 drivers/atm/zatm.c       |    6 ++----
 7 files changed, 16 insertions(+), 47 deletions(-)

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index 6cc93de..ac2c108 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -113,15 +113,13 @@ static int __init adummy_init(void)
 
 	printk(KERN_ERR "adummy: version %s\n", DRV_VERSION);
 
-	adummy_dev = (struct adummy_dev *) kmalloc(sizeof(struct adummy_dev),
+	adummy_dev = kzalloc(sizeof(struct adummy_dev),
 						   GFP_KERNEL);
 	if (!adummy_dev) {
-		printk(KERN_ERR DEV_LABEL ": kmalloc() failed\n");
+		printk(KERN_ERR DEV_LABEL ": kzalloc() failed\n");
 		err = -ENOMEM;
 		goto out;
 	}
-	memset(adummy_dev, 0, sizeof(struct adummy_dev));
-
 	atm_dev = atm_dev_register(DEV_LABEL, &adummy_ops, -1, NULL);
 	if (!atm_dev) {
 		printk(KERN_ERR DEV_LABEL ": atm_dev_register() failed\n");
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 38fc054..7c75adf 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1784,7 +1784,7 @@ static int __devinit fs_init (struct fs_
 		write_fs (dev, RAM, (1 << (28 - FS155_VPI_BITS - FS155_VCI_BITS)) - 1);
 		dev->nchannels = FS155_NR_CHANNELS;
 	}
-	dev->atm_vccs = kmalloc (dev->nchannels * sizeof (struct atm_vcc *), 
+	dev->atm_vccs = kcalloc (dev->nchannels, sizeof (struct atm_vcc *), 
 				 GFP_KERNEL);
 	fs_dprintk (FS_DEBUG_ALLOC, "Alloc atmvccs: %p(%Zd)\n",
 		    dev->atm_vccs, dev->nchannels * sizeof (struct atm_vcc *));
@@ -1794,9 +1794,8 @@ static int __devinit fs_init (struct fs_
 		/* XXX Clean up..... */
 		return 1;
 	}
-	memset (dev->atm_vccs, 0, dev->nchannels * sizeof (struct atm_vcc *));
 
-	dev->tx_inuse = kmalloc (dev->nchannels / 8 /* bits/byte */ , GFP_KERNEL);
+	dev->tx_inuse = kzalloc (dev->nchannels / 8 /* bits/byte */ , GFP_KERNEL);
 	fs_dprintk (FS_DEBUG_ALLOC, "Alloc tx_inuse: %p(%d)\n", 
 		    dev->atm_vccs, dev->nchannels / 8);
 
@@ -1805,8 +1804,6 @@ static int __devinit fs_init (struct fs_
 		/* XXX Clean up..... */
 		return 1;
 	}
-	memset (dev->tx_inuse, 0, dev->nchannels / 8);
-
 	/* -- RAS1 : FS155 and 50 differ. Default (0) should be OK for both */
 	/* -- RAS2 : FS50 only: Default is OK. */
 
@@ -1893,14 +1890,11 @@ static int __devinit firestream_init_one
 	if (pci_enable_device(pci_dev)) 
 		goto err_out;
 
-	fs_dev = kmalloc (sizeof (struct fs_dev), GFP_KERNEL);
+	fs_dev = kzalloc (sizeof (struct fs_dev), GFP_KERNEL);
 	fs_dprintk (FS_DEBUG_ALLOC, "Alloc fs-dev: %p(%Zd)\n",
 		    fs_dev, sizeof (struct fs_dev));
 	if (!fs_dev)
 		goto err_out;
-
-	memset (fs_dev, 0, sizeof (struct fs_dev));
-  
 	atm_dev = atm_dev_register("fs", &ops, -1, NULL);
 	if (!atm_dev)
 		goto err_out_free_fs_dev;
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index f2511b4..b22a914 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -383,14 +383,12 @@ he_init_one(struct pci_dev *pci_dev, con
 	}
 	pci_set_drvdata(pci_dev, atm_dev);
 
-	he_dev = (struct he_dev *) kmalloc(sizeof(struct he_dev),
+	he_dev = kzalloc(sizeof(struct he_dev),
 							GFP_KERNEL);
 	if (!he_dev) {
 		err = -ENOMEM;
 		goto init_one_failure;
 	}
-	memset(he_dev, 0, sizeof(struct he_dev));
-
 	he_dev->pci_dev = pci_dev;
 	he_dev->atm_dev = atm_dev;
 	he_dev->atm_dev->dev_data = he_dev;
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index d1113e8..209dba1 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2719,7 +2719,7 @@ static int __devinit hrz_probe(struct pc
 		goto out_disable;
 	}
 
-	dev = kmalloc(sizeof(hrz_dev), GFP_KERNEL);
+	dev = kzalloc(sizeof(hrz_dev), GFP_KERNEL);
 	if (!dev) {
 		// perhaps we should be nice: deregister all adapters and abort?
 		PRINTD(DBG_ERR, "out of memory");
@@ -2727,8 +2727,6 @@ static int __devinit hrz_probe(struct pc
 		goto out_release;
 	}
 
-	memset(dev, 0, sizeof(hrz_dev));
-
 	pci_set_drvdata(pci_dev, dev);
 
 	// grab IRQ and install handler - move this someplace more sensible
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index b0369bb..7487f0a 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -642,11 +642,9 @@ alloc_scq(struct idt77252_dev *card, int
 {
 	struct scq_info *scq;
 
-	scq = (struct scq_info *) kmalloc(sizeof(struct scq_info), GFP_KERNEL);
+	scq = kzalloc(sizeof(struct scq_info), GFP_KERNEL);
 	if (!scq)
 		return NULL;
-	memset(scq, 0, sizeof(struct scq_info));
-
 	scq->base = pci_alloc_consistent(card->pcidev, SCQ_SIZE,
 					 &scq->paddr);
 	if (scq->base == NULL) {
@@ -2142,11 +2140,9 @@ idt77252_init_est(struct vc_map *vc, int
 {
 	struct rate_estimator *est;
 
-	est = kmalloc(sizeof(struct rate_estimator), GFP_KERNEL);
+	est = kzalloc(sizeof(struct rate_estimator), GFP_KERNEL);
 	if (!est)
 		return NULL;
-	memset(est, 0, sizeof(*est));
-
 	est->maxcps = pcr < 0 ? -pcr : pcr;
 	est->cps = est->maxcps;
 	est->avcps = est->cps << 5;
@@ -2451,14 +2447,12 @@ idt77252_open(struct atm_vcc *vcc)
 
 	index = VPCI2VC(card, vpi, vci);
 	if (!card->vcs[index]) {
-		card->vcs[index] = kmalloc(sizeof(struct vc_map), GFP_KERNEL);
+		card->vcs[index] = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
 		if (!card->vcs[index]) {
 			printk("%s: can't alloc vc in open()\n", card->name);
 			up(&card->mutex);
 			return -ENOMEM;
 		}
-		memset(card->vcs[index], 0, sizeof(struct vc_map));
-
 		card->vcs[index]->card = card;
 		card->vcs[index]->index = index;
 
@@ -2926,13 +2920,11 @@ open_card_oam(struct idt77252_dev *card)
 		for (vci = 3; vci < 5; vci++) {
 			index = VPCI2VC(card, vpi, vci);
 
-			vc = kmalloc(sizeof(struct vc_map), GFP_KERNEL);
+			vc = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
 			if (!vc) {
 				printk("%s: can't alloc vc\n", card->name);
 				return -ENOMEM;
 			}
-			memset(vc, 0, sizeof(struct vc_map));
-
 			vc->index = index;
 			card->vcs[index] = vc;
 
@@ -2995,12 +2987,11 @@ open_card_ubr0(struct idt77252_dev *card
 {
 	struct vc_map *vc;
 
-	vc = kmalloc(sizeof(struct vc_map), GFP_KERNEL);
+	vc = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
 	if (!vc) {
 		printk("%s: can't alloc vc\n", card->name);
 		return -ENOMEM;
 	}
-	memset(vc, 0, sizeof(struct vc_map));
 	card->vcs[0] = vc;
 	vc->class = SCHED_UBR0;
 
@@ -3695,14 +3686,12 @@ idt77252_init_one(struct pci_dev *pcidev
 		goto err_out_disable_pdev;
 	}
 
-	card = kmalloc(sizeof(struct idt77252_dev), GFP_KERNEL);
+	card = kzalloc(sizeof(struct idt77252_dev), GFP_KERNEL);
 	if (!card) {
 		printk("idt77252-%d: can't allocate private data\n", index);
 		err = -ENOMEM;
 		goto err_out_disable_pdev;
 	}
-	memset(card, 0, sizeof(struct idt77252_dev));
-
 	card->revision = revision;
 	card->index = index;
 	card->pcidev = pcidev;
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index fe60a59..b9568e1 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -1482,16 +1482,10 @@ #endif
 static inline struct lanai_vcc *new_lanai_vcc(void)
 {
 	struct lanai_vcc *lvcc;
-	lvcc = (struct lanai_vcc *) kmalloc(sizeof(*lvcc), GFP_KERNEL);
+	lvcc =  kzalloc(sizeof(*lvcc), GFP_KERNEL);
 	if (likely(lvcc != NULL)) {
-		lvcc->vbase = NULL;
-		lvcc->rx.atmvcc = lvcc->tx.atmvcc = NULL;
-		lvcc->nref = 0;
-		memset(&lvcc->stats, 0, sizeof lvcc->stats);
-		lvcc->rx.buf.start = lvcc->tx.buf.start = NULL;
 		skb_queue_head_init(&lvcc->tx.backlog);
 #ifdef DEBUG
-		lvcc->tx.unqueue = NULL;
 		lvcc->vci = -1;
 #endif
 	}
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 2c65e82..c491ec4 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -603,9 +603,8 @@ static int start_rx(struct atm_dev *dev)
 DPRINTK("start_rx\n");
 	zatm_dev = ZATM_DEV(dev);
 	size = sizeof(struct atm_vcc *)*zatm_dev->chans;
-	zatm_dev->rx_map = (struct atm_vcc **) kmalloc(size,GFP_KERNEL);
+	zatm_dev->rx_map =  kzalloc(size,GFP_KERNEL);
 	if (!zatm_dev->rx_map) return -ENOMEM;
-	memset(zatm_dev->rx_map,0,size);
 	/* set VPI/VCI split (use all VCIs and give what's left to VPIs) */
 	zpokel(zatm_dev,(1 << dev->ci_range.vci_bits)-1,uPD98401_VRR);
 	/* prepare free buffer pools */
@@ -951,9 +950,8 @@ static int open_tx_first(struct atm_vcc 
 	skb_queue_head_init(&zatm_vcc->tx_queue);
 	init_waitqueue_head(&zatm_vcc->tx_wait);
 	/* initialize ring */
-	zatm_vcc->ring = kmalloc(RING_SIZE,GFP_KERNEL);
+	zatm_vcc->ring = kzalloc(RING_SIZE,GFP_KERNEL);
 	if (!zatm_vcc->ring) return -ENOMEM;
-	memset(zatm_vcc->ring,0,RING_SIZE);
 	loop = zatm_vcc->ring+RING_ENTRIES*RING_WORDS;
 	loop[0] = uPD98401_TXPD_V;
 	loop[1] = loop[2] = 0;
