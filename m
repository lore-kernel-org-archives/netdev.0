From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] drivers/net/bna: Use pr_<level>, dev_<level>, remove DPRINTK
Date: Mon, 23 Nov 2009 23:24:11 -0800
Message-ID: <802488490160270a74fb67c427b6ddef1480e204.1259047344.git.joe@perches.com>
References: <cover.1259047344.git.joe@perches.com>
Cc: adapter_linux_open_src_team@brocade.com, netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1117 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbZKXHYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 02:24:07 -0500
In-Reply-To: <cover.1259047344.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove DPRINTK(LEVEL, fmt, arg) and convert uses to pr_<level>
Convert printk(KERN_<LEVEL> to pr_<level>
Use dev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bna/bfa_csdebug.c |   10 +--
 drivers/net/bna/bfa_ioc.c     |    5 +-
 drivers/net/bna/bfad_fwimg.c  |    8 +-
 drivers/net/bna/bna_fn.c      |    7 +-
 drivers/net/bna/bna_if.c      |   48 +++++-------
 drivers/net/bna/bnad.c        |  171 +++++++++++++++-------------------------
 drivers/net/bna/bnad_compat.h |   13 ---
 drivers/net/bna/cna.h         |    5 -
 8 files changed, 97 insertions(+), 170 deletions(-)

diff --git a/drivers/net/bna/bfa_csdebug.c b/drivers/net/bna/bfa_csdebug.c
index c0ef773..c9f3480 100644
--- a/drivers/net/bna/bfa_csdebug.c
+++ b/drivers/net/bna/bfa_csdebug.c
@@ -20,6 +20,8 @@
  *  pbind.c BFA FC Persistent target binding
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "cs/bfa_debug.h"
 #include "cna.h"
 #include "cs/bfa_q.h"
@@ -31,18 +33,14 @@
 void
 bfa_panic(int line, char *file, char *panicstr)
 {
-
-	DPRINTK(ERR, "Assertion failure: %s:%d: %s",
-		file, line, panicstr);
+	pr_err("Assertion failure: %s:%d: %s\n", file, line, panicstr);
 	bfa_os_panic();
 }
 
 void
 bfa_sm_panic(struct bfa_log_mod *logm, int line, char *file, int event)
 {
-
-	DPRINTK(ERR, "SM Assertion failure: %s:%d: event = %d",
-		file, line, event);
+	pr_err("SM Assertion failure: %s:%d: event = %d\n", file, line, event);
 	bfa_os_panic();
 }
 
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index b572cc5..f601850 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -16,6 +16,8 @@
  * www.brocade.com
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "bfa_ioc.h"
 #include "bfa_fwimg_priv.h"
 #include "cs/bfa_debug.h"
@@ -1015,8 +1017,7 @@ bfa_ioc_hb_check(void *cbarg)
 
 	hb_count = bfa_reg_read(ioc->ioc_regs.heartbeat);
 	if (ioc->hb_count == hb_count) {
-
-		DPRINTK(CRIT, "Firmware heartbeat failure at %d", hb_count);
+		pr_crit("Firmware heartbeat failure at %d\n", hb_count);
 		bfa_ioc_recover(ioc);
 		return;
 	} else {
diff --git a/drivers/net/bna/bfad_fwimg.c b/drivers/net/bna/bfad_fwimg.c
index 37fa6d5..d1ad2e2 100644
--- a/drivers/net/bna/bfad_fwimg.c
+++ b/drivers/net/bna/bfad_fwimg.c
@@ -16,6 +16,8 @@
  * www.brocade.com
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 /**
  *  bfad_fwimg.c Linux driver PCI interface module.
  */
@@ -47,14 +49,14 @@ bfad_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
 	const struct firmware *fw;
 
 	if (request_firmware(&fw, fw_name, &pdev->dev)) {
-		printk(KERN_ALERT "Can't locate firmware %s\n", fw_name);
+		pr_alert("Can't locate firmware %s\n", fw_name);
 		goto error;
 	}
 
 	*bfi_image = vmalloc(fw->size);
 	if (NULL == *bfi_image) {
-		printk(KERN_ALERT "Fail to allocate buffer for fw image "
-			"size=%x!\n", (u32) fw->size);
+		pr_alert("Fail to allocate buffer for fw image size=%x!\n",
+			 (u32)fw->size);
 		goto error;
 	}
 
diff --git a/drivers/net/bna/bna_fn.c b/drivers/net/bna/bna_fn.c
index 01218ca..03d4e94 100644
--- a/drivers/net/bna/bna_fn.c
+++ b/drivers/net/bna/bna_fn.c
@@ -18,6 +18,8 @@
  *    @file bna_fn.c BNA Rx and Tx Function Management
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "cna.h"
 #include "bna.h"
 #include "bna_hwreg.h"
@@ -657,14 +659,11 @@ enum bna_status_e bna_rxf_mcast_mac_set_list(struct bna_dev *dev,
 {
 	u32 i, j;
 	int found;
-	char message[BNA_MESSAGE_SIZE];
 
 	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
 
 	if (mac_addr_num > BNA_MCAST_TABLE_SIZE) {
-		sprintf(message, "Too many Multicast Addresses [%d]",
-			       mac_addr_num);
-		DPRINTK(INFO, "%s", message);
+		pr_info("Too many Multicast Addresses [%d]\n", mac_addr_num);
 		return BNA_FAIL;
 	}
 
diff --git a/drivers/net/bna/bna_if.c b/drivers/net/bna/bna_if.c
index 034b352..7f327fb 100644
--- a/drivers/net/bna/bna_if.c
+++ b/drivers/net/bna/bna_if.c
@@ -17,6 +17,9 @@
  *
  *	file bna_if.c BNA Hardware and Firmware Interface
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "cna.h"
 #include "bna.h"
 #include "bna_hwreg.h"
@@ -271,30 +274,24 @@ enum bna_status_e bna_mbox_send(struct bna_dev *dev, void *cmd,
 	struct bna_mbox_q *q;
 	struct bfi_mhdr *mh = (struct bfi_mhdr *)cmd;
 
-	char message[BNA_MESSAGE_SIZE];
 	BNA_ASSERT(cmd_len <= BNA_MAX_MBOX_CMD_LEN);
 
 	if (dev->ioc_disable_pending) {
-		sprintf(message,
-			       "IOC Disable is pending : Cannot queue Cmd "
-			       "class %d id %d", mh->msg_class, mh->msg_id);
-		DPRINTK(INFO, "%s", message);
+		pr_info("IOC Disable is pending : Cannot queue Cmd class %d id %d\n",
+			mh->msg_class, mh->msg_id);
 		return BNA_AGAIN;
 	}
 
 	if (!bfa_ioc_is_operational(&dev->ioc)) {
-		sprintf(message,
-			       "IOC is not operational : Cannot queue Cmd "
-			       "class %d id %d", mh->msg_class, mh->msg_id);
-		DPRINTK(INFO, "%s", message);
+		pr_info("IOC is not operational : Cannot queue Cmd class %d id %d\n",
+			mh->msg_class, mh->msg_id);
 		return BNA_AGAIN;
 	}
 
 	q = &dev->mbox_q;
 	qe = bna_mbox_enq(q, cmd, cmd_len, cbarg);
 	if (qe == NULL) {
-		sprintf(message, "No free Mbox Command Element");
-		DPRINTK(INFO, "%s", message);
+		pr_info("No free Mbox Command Element\n");
 		return BNA_FAIL;
 	}
 	return bna_chk_n_snd_q(dev);
@@ -312,11 +309,9 @@ static int bna_is_aen(u8 msg_id)
 static void bna_err_handler(struct bna_dev *dev, u32 intr_status)
 {
 	u32 curr_mask, init_halt;
-	char message[BNA_MESSAGE_SIZE];
 
-	sprintf(message, "HW ERROR : INT statux 0x%x on port %d",
-		       intr_status, dev->port);
-		DPRINTK(INFO, "%s", message);
+	pr_info("HW ERROR : INT statux 0x%x on port %d\n",
+		intr_status, dev->port);
 
 	if (intr_status & __HALT_STATUS_BITS) {
 		init_halt = bfa_reg_read(dev->ioc.ioc_regs.ll_halt);
@@ -343,7 +338,6 @@ void bna_ll_isr(void *llarg, struct bfi_mbmsg *msg)
 	struct bna_mbox_cmd_qe *qe = NULL;
 	struct bna_mbox_q *mbox_q = NULL;
 	struct bfi_ll_rsp *mb_rsp = NULL;
-	char message[BNA_MESSAGE_SIZE];
 
 	mb_rsp = (struct bfi_ll_rsp *)(msg);
 
@@ -359,17 +353,14 @@ void bna_ll_isr(void *llarg, struct bfi_mbmsg *msg)
 
 		if (BFA_I2HM(((struct bfi_mhdr *)(&qe->cmd.msg[0]))->msg_id)
 		    != mb_rsp->mh.msg_id) {
-			sprintf(message,
-				       "Invalid Rsp Msg %d:%d (Expected %d:%d) "
-				       "on %d", mb_rsp->mh.msg_class,
-				       mb_rsp->mh.msg_id,
-				       ((struct bfi_mhdr *)(&qe->cmd.
-							      msg[0]))->
+			pr_info("Invalid Rsp Msg %d:%d (Expected %d:%d) on %d\n",
+				mb_rsp->mh.msg_class,
+				mb_rsp->mh.msg_id,
+				((struct bfi_mhdr *)(&qe->cmd.msg[0]))->
 				       msg_class,
-				       BFA_I2HM(((struct bfi_mhdr *)
-						 (&qe->cmd.msg[0]))->msg_id),
-				       dev->port);
-		DPRINTK(INFO, "%s", message);
+				BFA_I2HM(((struct bfi_mhdr *)
+					  (&qe->cmd.msg[0]))->msg_id),
+				dev->port);
 			BNA_ASSERT(0);
 			return;
 		}
@@ -523,14 +514,11 @@ void bna_iocll_attach(struct bna_dev *dev, void *bnad,
 enum bna_status_e bna_iocll_disable(struct bna_dev *dev)
 {
 	enum bna_status_e ret;
-	char message[BNA_MESSAGE_SIZE];
 
 	dev->ioc_disable_pending = 1;
 	ret = bna_flush_mbox_q(dev, 1);
 	if (ret != BNA_OK) {
-		sprintf(message, "Unable to flush Mbox Queues [%d]",
-			       ret);
-		DPRINTK(INFO, "%s", message);
+		pr_info("Unable to flush Mbox Queues [%d]\n", ret);
 		return ret;
 	}
 
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 26bd9c8..28df975 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -20,6 +20,8 @@
  *  bnad.c  Brocade 10G PCIe Ethernet driver.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
@@ -602,7 +604,6 @@ static int bnad_request_txrx_irqs(struct bnad *bnad)
 	struct msix_entry *entries;
 	int i;
 	int err;
-	char message[BNA_MESSAGE_SIZE];
 
 	if (!(bnad->config & BNAD_CF_MSIX)) {
 		u32 mask;
@@ -618,8 +619,9 @@ static int bnad_request_txrx_irqs(struct bnad *bnad)
 	for (i = 0; i < bnad->txq_num; i++) {
 		err = bnad_request_txq_irq(bnad, i);
 		if (err) {
-			sprintf(message, "%s request irq for TxQ %d failed %d",
-				bnad->netdev->name, i, err);
+			dev_info(&bnad->netdev->dev,
+				 "request irq for TxQ %d failed %d\n",
+				 i, err);
 			while (--i >= 0) {
 				free_irq(entries[i].vector,
 					 &bnad->txq_table[i]);
@@ -631,8 +633,9 @@ static int bnad_request_txrx_irqs(struct bnad *bnad)
 	for (i = 0; i < bnad->cq_num; i++) {
 		err = bnad_request_cq_irq(bnad, i);
 		if (err) {
-			sprintf(message, "%s request irq for CQ %u failed %d",
-				bnad->netdev->name, i, err);
+			dev_info(&bnad->netdev->dev,
+				 "request irq for CQ %u failed %d\n",
+				 i, err);
 			while (--i >= 0) {
 				free_irq(entries[bnad->txq_num + i].vector,
 					 &bnad->cq_table[i]);
@@ -793,7 +796,6 @@ static void bnad_stats_get_cb(void *arg, u8 status)
 static void bnad_hw_error(struct bnad *bnad, u8 status)
 {
 	unsigned int irq;
-	char message[BNA_MESSAGE_SIZE];
 
 	set_bit(BNAD_F_HWERROR, &bnad->flags);
 
@@ -801,10 +803,9 @@ static void bnad_hw_error(struct bnad *bnad, u8 status)
 	if (bnad->config & BNAD_CF_MSIX) {
 		if (!test_and_set_bit(BNAD_F_MBOX_IRQ_DISABLED, &bnad->flags)) {
 			irq = bnad->msix_table[bnad->msix_num - 1].vector;
-			sprintf(message, "Disabling Mbox IRQ %d for port %d",
-				irq, bnad->bna_id);
-		DPRINTK(INFO, "%s",
-				message);
+			dev_info(&bnad->netdev->dev,
+				 "Disabling Mbox IRQ %d for port %d\n",
+				 irq, bnad->bna_id);
 			disable_irq_nosync(irq);
 		}
 	}
@@ -841,16 +842,15 @@ static int bnad_alloc_unmap_queues(struct bnad *bnad)
 	int i, err = 0;
 	struct bnad_txq_info *txqinfo;
 	struct bnad_rxq_info *rxqinfo;
-	char message[BNA_MESSAGE_SIZE];
 
 	for (i = 0; i < bnad->txq_num; i++) {
 		txqinfo = &bnad->txq_table[i];
 		err = bnad_alloc_unmap_q(&txqinfo->skb_unmap_q,
 					 txqinfo->txq.q.q_depth * 4);
 		if (err) {
-			sprintf(message,
-				"%s allocating Tx unmap Q %d failed: %d",
-				bnad->netdev->name, i, err);
+			dev_info(&bnad->netdev->dev,
+				 "allocating Tx unmap Q %d failed: %d\n",
+				 i, err);
 			return err;
 		}
 	}
@@ -859,9 +859,9 @@ static int bnad_alloc_unmap_queues(struct bnad *bnad)
 		err = bnad_alloc_unmap_q(&rxqinfo->skb_unmap_q,
 					 rxqinfo->rxq.q.q_depth);
 		if (err) {
-			sprintf(message,
-				"%s allocating Rx unmap Q %d failed: %d",
-				bnad->netdev->name, i, err);
+			dev_info(&bnad->netdev->dev,
+				 "allocating Rx unmap Q %d failed: %d\n",
+				 i, err);
 			return err;
 		}
 	}
@@ -918,7 +918,6 @@ static void bnad_flush_rxbufs(struct bnad_rxq_info *rxqinfo)
 static int bnad_disable_txq(struct bnad *bnad, u32 txq_id)
 {
 	int err;
-	char message[BNA_MESSAGE_SIZE];
 
 	WARN_ON(in_interrupt());
 
@@ -949,9 +948,9 @@ static int bnad_disable_txq(struct bnad *bnad, u32 txq_id)
 
 txq_stop_exit:
 	if (err) {
-		sprintf(message, "%s stop TxQ %u failed %d", bnad->netdev->name,
-			txq_id, err);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev,
+			 "stop TxQ %u failed %d\n",
+			 txq_id, err);
 	}
 
 	return err;
@@ -961,7 +960,6 @@ txq_stop_exit:
 int bnad_disable_rxqs(struct bnad *bnad, u64 rxq_id_mask)
 {
 	int err;
-	char message[BNA_MESSAGE_SIZE];
 
 	WARN_ON(in_interrupt());
 
@@ -993,9 +991,8 @@ int bnad_disable_rxqs(struct bnad *bnad, u64 rxq_id_mask)
 
 rxq_stop_exit:
 	if (err) {
-		sprintf(message, "%s stop RxQs(0x%llu) failed %d",
-			bnad->netdev->name, rxq_id_mask, err);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "stop RxQs(0x%llu) failed %d\n",
+			 rxq_id_mask, err);
 	}
 
 	return err;
@@ -1125,15 +1122,13 @@ static void bnad_port_admin_locked(struct bnad *bnad, u8 up)
 static int bnad_stop_locked_internal(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
-	char message[BNA_MESSAGE_SIZE];
 
 	switch (bnad->state) {
 	case BNAD_S_OPEN:
 		bnad->state = BNAD_S_CLOSING;
 		bnad_disable_locked(bnad);
 		bnad->state = BNAD_S_INIT;
-		sprintf(message, "%s is stopped", bnad->netdev->name);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "is stopped\n");
 		break;
 	case BNAD_S_OPEN_DOWN:
 		bnad->state = BNAD_S_INIT_DOWN;
@@ -1889,33 +1884,26 @@ static int bnad_enable_locked(struct bnad *bnad)
 	struct net_device *netdev = bnad->netdev;
 	int err = 0;
 	uint i;
-	char message[BNA_MESSAGE_SIZE];
 
 	bnad->state = BNAD_S_OPENING;
 
 	err = bnad_init(bnad);
 	if (err) {
-		sprintf(message, "%s init failed %d", netdev->name, err);
-		DPRINTK(INFO, "%s",
-			message);
+		dev_info(&netdev->dev, "init failed %d\n", err);
 		bnad->state = BNAD_S_INIT;
 		return err;
 	}
 
 	err = bnad_config_hw(bnad);
 	if (err) {
-		sprintf(message, "%s config HW failed %d", netdev->name, err);
-		DPRINTK(INFO, "%s",
-			message);
+		dev_info(&netdev->dev, "config HW failed %d\n", err);
 		goto init_failed;
 	}
 
 	err = bnad_request_txrx_irqs(bnad);
 	if (err) {
-		sprintf(message, "%s requests Tx/Rx irqs failed: %d",
-			bnad->netdev->name, err);
-		DPRINTK(INFO, "%s",
-			message);
+		dev_info(&bnad->netdev->dev,
+			 "requests Tx/Rx irqs failed: %d\n", err);
 		goto init_failed;
 	}
 	bnad_napi_init(bnad);
@@ -1924,8 +1912,7 @@ static int bnad_enable_locked(struct bnad *bnad)
 		bnad_alloc_for_rxq(bnad, i);
 
 	bnad->state = BNAD_S_OPEN;
-	sprintf(message, "%s is opened", bnad->netdev->name);
-		DPRINTK(INFO, "%s", message);
+	dev_info(&bnad->netdev->dev, "is opened\n");
 
 	spin_lock_irq(&bnad->priv_lock);
 	if (BNAD_NOT_READY(bnad)) {
@@ -1951,7 +1938,6 @@ static int bnad_open_locked_internal(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int err = 0;
-	char message[BNA_MESSAGE_SIZE];
 
 	switch (bnad->state) {
 	case BNAD_S_INIT:
@@ -1959,14 +1945,11 @@ static int bnad_open_locked_internal(struct net_device *netdev)
 		break;
 	case BNAD_S_INIT_DOWN:
 		bnad->state = BNAD_S_OPEN_DOWN;
-		sprintf(message, "%s is not ready yet: IOC down", netdev->name);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "is not ready yet: IOC down\n");
 		break;
 	case BNAD_S_INIT_DISABLED:
 		bnad->state = BNAD_S_OPEN_DISABLED;
-		sprintf(message, "%s is not ready yet: IOC disabled",
-			netdev->name);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "is not ready yet: IOC disabled\n");
 		break;
 	default:
 		BNA_ASSERT(0);
@@ -1992,16 +1975,13 @@ int bnad_open(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int err = 0;
-	char message[BNA_MESSAGE_SIZE];
 
-	sprintf(message, "%s open", netdev->name);
-		DPRINTK(INFO, "%s", message);
+	dev_info(&bnad->netdev->dev, "open\n");
 
 	bnad_conf_lock();
 
 	if (test_bit(BNAD_F_BCU_DISABLED, &bnad->flags)) {
-		sprintf(message, "%s is disabled", netdev->name);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "is disabled\n");
 	} else
 		err = bnad_open_locked(netdev);
 
@@ -2050,16 +2030,13 @@ int bnad_stop(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int err = 0;
-	char message[BNA_MESSAGE_SIZE];
 
-	sprintf(message, "%s stop", netdev->name);
-		DPRINTK(INFO, "%s", message);
+	dev_info(&bnad->netdev->dev, "stop\n");
 
 	bnad_conf_lock();
 
 	if (test_bit(BNAD_F_BCU_DISABLED, &bnad->flags)) {
-		sprintf(message, "%s port is disabled", netdev->name);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "port is disabled\n");
 	} else
 		err = bnad_stop_locked(netdev);
 
@@ -2073,25 +2050,25 @@ int bnad_sw_reset_locked_internal(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int err;
-	char message[BNA_MESSAGE_SIZE];
 
 	err = bnad_stop_locked_internal(netdev);
 	if (err) {
-		sprintf(message, "%s sw reset internal: stop failed %d",
-			bnad->netdev->name, err);
+		dev_info(&bnad->netdev->dev,
+			 "sw reset internal: stop failed %d\n",
+			 err);
 		goto done;
 	}
 
 	err = bnad_open_locked_internal(netdev);
 
 	if (err) {
-		sprintf(message, "%s sw reset internal: open failed %d",
-			bnad->netdev->name, err);
+		dev_info(&bnad->netdev->dev,
+			 "sw reset internal: open failed %d\n",
+			 err);
 		goto done;
 	}
 	return 0;
 done:
-		DPRINTK(INFO, "%s", message);
 	return err;
 }
 
@@ -2100,7 +2077,6 @@ int bnad_sw_reset_locked(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int err;
-	char message[BNA_MESSAGE_SIZE];
 
 	if (bnad->state != BNAD_S_OPEN)
 		return 0;
@@ -2110,9 +2086,7 @@ int bnad_sw_reset_locked(struct net_device *netdev)
 	err = bnad_sw_reset_locked_internal(netdev);
 
 	if (err) {
-		sprintf(message, "%s sw reset: failed %d", bnad->netdev->name,
-			err);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "sw reset: failed %d\n", err);
 		return err;
 	}
 
@@ -2484,7 +2458,6 @@ int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id, u8 * mac_ptr,
 	unsigned int cmd)
 {
 	int err = 0;
-	char message[BNA_MESSAGE_SIZE];
 	enum bna_status_e(*ucast_mac_func) (struct bna_dev *bna_dev,
 		unsigned int rxf_id, const struct mac *mac_addr_ptr) = NULL;
 
@@ -2520,10 +2493,9 @@ int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id, u8 * mac_ptr,
 
 ucast_mac_exit:
 	if (err) {
-		sprintf(message, "%s unicast MAC address command %d failed: %d",
-			bnad->netdev->name, cmd, err);
-		DPRINTK(INFO, "%s",
-			message);
+		dev_info(&bnad->netdev->dev,
+			 "unicast MAC address command %d failed: %d\n",
+			 cmd, err);
 		return -EINVAL;
 	}
 
@@ -2793,7 +2765,6 @@ static void bnad_resume_after_reset(struct bnad *bnad)
 {
 	int err;
 	struct net_device *netdev = bnad->netdev;
-	char message[BNA_MESSAGE_SIZE];
 
 	switch (bnad->state) {
 	case BNAD_S_INIT_DOWN:
@@ -2809,11 +2780,9 @@ static void bnad_resume_after_reset(struct bnad *bnad)
 	case BNAD_S_OPEN_DOWN:
 		err = bnad_enable_locked(bnad);
 		if (err) {
-			sprintf(message,
-				"%s bnad_enable failed after reset: %d",
-				bnad->netdev->name, err);
-		DPRINTK(INFO, "%s",
-				message);
+			dev_info(&bnad->netdev->dev,
+				 "bnad_enable failed after reset: %d\n",
+				 err);
 		} else {
 			bnad_port_admin_locked(bnad, BNA_ENABLE);
 		}
@@ -2875,12 +2844,10 @@ static void bnad_link_state_notify(struct bnad *bnad)
 	enum bnad_link_state link_state;
 	u8 cee_linkup;
 	unsigned int prio = 0;
-	char message[BNA_MESSAGE_SIZE];
 
 	if (bnad->state != BNAD_S_OPEN) {
-		sprintf(message, "%s link up in state %d", netdev->name,
-			bnad->state);
-		DPRINTK(INFO, "%s", message);
+		dev_info(&bnad->netdev->dev, "link up in state %d\n",
+			 bnad->state);
 		return;
 	}
 
@@ -3138,7 +3105,7 @@ static int bnad_priv_init(struct bnad *bnad)
 	/* XXX could be vmalloc? */
 	bnad->trcmod = kzalloc(sizeof(struct bfa_trc_mod), GFP_KERNEL);
 	if (!bnad->trcmod) {
-		printk(KERN_ERR "port %u failed allocating trace buffer!\n",
+		pr_err("port %u failed allocating trace buffer!\n",
 		       bnad->bna_id);
 		return -ENOMEM;
 	}
@@ -3149,7 +3116,7 @@ static int bnad_priv_init(struct bnad *bnad)
 
 	bnad->priv = kzalloc(bna_get_handle_size(), GFP_KERNEL);
 	if (!bnad->priv) {
-		printk(KERN_ERR "port %u failed allocating memory for bna\n",
+		pr_err("port %u failed allocating memory\n",
 		       bnad->bna_id);
 		err = -ENOMEM;
 		goto free_trcmod;
@@ -3158,8 +3125,7 @@ static int bnad_priv_init(struct bnad *bnad)
 		pci_alloc_consistent(bnad->pcidev, BNA_HW_STATS_SIZE,
 				     &dma_addr);
 	if (!bnad->priv_stats) {
-		printk(KERN_ERR
-		       "port %u failed allocating memory for bna stats\n",
+		pr_err("port %u failed allocating memory for bna stats\n",
 		       bnad->bna_id);
 		err = -ENOMEM;
 		goto free_priv_mem;
@@ -3203,9 +3169,7 @@ static int bnad_priv_init(struct bnad *bnad)
 			break;
 		}
 		if (!bnad->ioc_meminfo[i].kva) {
-			printk(KERN_ERR
-			       "port %u failed allocating %u "
-			       "bytes memory for IOC\n",
+			pr_err("port %u failed allocating %u bytes memory for IOC\n",
 			       bnad->bna_id, bnad->ioc_meminfo[i].len);
 			err = -ENOMEM;
 			goto free_ioc_mem;
@@ -3223,8 +3187,7 @@ static int bnad_priv_init(struct bnad *bnad)
 
 	err = bnad_cee_attach(bnad);
 	if (err) {
-		printk(KERN_ERR "port %u cee_attach failed: %d\n", bnad->bna_id,
-		       err);
+		pr_err("port %u cee_attach failed: %d\n", bnad->bna_id, err);
 		goto iocll_detach;
 	}
 
@@ -3287,7 +3250,6 @@ static void bnad_priv_uninit(struct bnad *bnad)
 {
 	int i;
 	enum bna_status_e err;
-	char message[BNA_MESSAGE_SIZE];
 
 	if (bnad->priv) {
 
@@ -3304,10 +3266,7 @@ static void bnad_priv_uninit(struct bnad *bnad)
 		}
 		if (err) {
 			/* Probably firmware crashed. */
-			sprintf(message,
-				"bna_iocll_disable failed, "
-				"clean up and try again");
-		DPRINTK(INFO, "%s", message);
+			pr_info("bna_iocll_disable failed, clean up and try again\n");
 			spin_lock_irq(&bnad->priv_lock);
 			bna_cleanup(bnad->priv);
 			err = bna_iocll_disable(bnad->priv);
@@ -3316,8 +3275,7 @@ static void bnad_priv_uninit(struct bnad *bnad)
 		}
 		wait_for_completion(&bnad->ioc_comp);
 
-		sprintf(message, "port %u IOC is disabled", bnad->bna_id);
-		DPRINTK(INFO, "%s", message);
+		pr_info("port %u IOC is disabled\n", bnad->bna_id);
 
 		bnad->state = BNAD_S_UNLOADING;
 
@@ -3370,11 +3328,11 @@ static int __devinit bnad_pci_probe(struct pci_dev *pdev,
 	unsigned long mmio_start, mmio_len;
 	static u32 bna_id;
 
-	printk(KERN_INFO "bnad_pci_probe : (0x%p, 0x%p) PCI Func : (%d)\n",
-	       pdev, pcidev_id, PCI_FUNC(pdev->devfn));
+	pr_info("%s: (0x%p, 0x%p) PCI Func : (%d)\n",
+		__func__, pdev, pcidev_id, PCI_FUNC(pdev->devfn));
 
 	if (!bfad_get_firmware_buf(pdev)) {
-		printk(KERN_WARNING "Failed to load Firmware Image!\n");
+		pr_warning("Failed to load Firmware Image!\n");
 		return -ENODEV;
 	}
 
@@ -3434,7 +3392,7 @@ static int __devinit bnad_pci_probe(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto free_devices;
 	}
-	printk(KERN_INFO "bar0 mapped to %p, len %lu\n", bnad->bar0, mmio_len);
+	pr_info("bar0 mapped to %p, len %lu\n", bnad->bar0, mmio_len);
 
 	netdev->netdev_ops = &bnad_netdev_ops;
 
@@ -3460,7 +3418,7 @@ static int __devinit bnad_pci_probe(struct pci_dev *pdev,
 	bnad->bna_id = bna_id;
 	err = bnad_priv_init(bnad);
 	if (err) {
-		printk(KERN_ERR "port %u init failed: %d\n", bnad->bna_id, err);
+		pr_err("port %u init failed: %d\n", bnad->bna_id, err);
 		goto unmap_bar0;
 	}
 
@@ -3471,7 +3429,7 @@ static int __devinit bnad_pci_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	err = register_netdev(netdev);
 	if (err) {
-		printk(KERN_ERR "port %u register_netdev failed: %d\n",
+		pr_err("port %u register_netdev failed: %d\n",
 		       bnad->bna_id, err);
 		goto bnad_device_uninit;
 	}
@@ -3501,7 +3459,7 @@ static void __devexit bnad_pci_remove(struct pci_dev *pdev)
 	if (!netdev)
 		return;
 
-	printk(KERN_INFO "%s bnad_pci_remove\n", netdev->name);
+	pr_info("%s bnad_pci_remove\n", netdev->name);
 	bnad = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
@@ -3523,8 +3481,7 @@ static struct pci_driver bnad_pci_driver = {
 
 static int __init bnad_module_init(void)
 {
-
-	printk(KERN_INFO "Brocade 10G Ethernet driver\n");
+	pr_info("Brocade 10G Ethernet driver\n");
 
 	bfa_ioc_auto_recover(bnad_ioc_auto_recover);
 
diff --git a/drivers/net/bna/bnad_compat.h b/drivers/net/bna/bnad_compat.h
index 98232e8..4e3c80c 100644
--- a/drivers/net/bna/bnad_compat.h
+++ b/drivers/net/bna/bnad_compat.h
@@ -73,19 +73,6 @@
 #define VERIFY_READ 0
 #endif
 
-#ifndef dev_err
-#define dev_err(dev, format, arg...)	\
-	printk(KERN_ERR "bna: " format, ## arg)
-#endif
-#ifndef dev_info
-#define dev_info(dev, format, arg...)	\
-	printk(KERN_INFO "bna: " format, ## arg)
-#endif
-#ifndef dev_warn
-#define dev_warn(dev, format, arg...)	\
-	printk(KERN_WARNING "bna: " format, ## arg)
-#endif
-
 #ifndef __force
 #define __force
 #endif
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index c75cdf5..4907041 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -49,11 +49,6 @@
 
 #define bfa_wtole(_x) cpu_to_le32((_x))
 
-#define PFX "BNA: "
-#define DPRINTK(klevel, fmt, args...) do {  \
-	printk(KERN_##klevel PFX fmt, ## args);      \
-} while (0)
-
 extern char bfa_version[];
 void bfa_ioc_auto_recover(bool auto_recover);
 
-- 
1.6.5.2.153.g6e31f

