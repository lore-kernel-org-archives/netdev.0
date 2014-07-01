From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC V2 2/2] net: qualcomm: new Ethernet over SPI driver
 for QCA7000
Date: Tue, 01 Jul 2014 10:37:26 -0700
Message-ID: <1404236246.14624.7.camel@joe-AO725>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
	 <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, eric.dumazet@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0111.hostedemail.com ([216.40.44.111]:59131 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755139AbaGARhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 13:37:31 -0400
In-Reply-To: <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-01 at 18:36 +0200, Stefan Wahren wrote:
> This patch adds the Ethernet over SPI driver for the
> Qualcomm QCA7000 HomePlug GreenPHY.

Beyond trivial comments about multi-line alignment and such,
it seems that qcaspi_receive might never return.

The dual while {} loops may never decrement available if
read_legacy or read_burst have errors.

count should be a local variable to the first while
not at function scope

btw: here are just those trivial bits:
---
 drivers/net/ethernet/qualcomm/qca_7k.c      |  1 -
 drivers/net/ethernet/qualcomm/qca_debug.c   | 26 ++++-----
 drivers/net/ethernet/qualcomm/qca_framing.c |  1 -
 drivers/net/ethernet/qualcomm/qca_spi.c     | 88 +++++++++++++++--------------
 4 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
index f7fc52b..2ddfc16 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k.c
@@ -146,4 +146,3 @@ qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
 
 	return ret;
 }
-
diff --git a/drivers/net/ethernet/qualcomm/qca_debug.c b/drivers/net/ethernet/qualcomm/qca_debug.c
index e88448c..8dd3936 100644
--- a/drivers/net/ethernet/qualcomm/qca_debug.c
+++ b/drivers/net/ethernet/qualcomm/qca_debug.c
@@ -70,7 +70,7 @@ qcaspi_info_show(struct seq_file *s, void *what)
 	struct qcaspi *qca = s->private;
 
 	seq_printf(s, "RX buffer size   : %lu\n",
-		(unsigned long) qca->buffer_size);
+		   (unsigned long)qca->buffer_size);
 
 	seq_puts(s, "TX ring state    : ");
 
@@ -84,10 +84,10 @@ qcaspi_info_show(struct seq_file *s, void *what)
 	seq_puts(s, "\n");
 
 	seq_printf(s, "TX ring size     : %u\n",
-		qca->txr.size);
+		   qca->txr.size);
 
 	seq_printf(s, "Sync state       : %u (",
-		(unsigned int) qca->sync);
+		   (unsigned int)qca->sync);
 	switch (qca->sync) {
 	case QCASPI_SYNC_UNKNOWN:
 		seq_puts(s, "QCASPI_SYNC_UNKNOWN");
@@ -105,22 +105,22 @@ qcaspi_info_show(struct seq_file *s, void *what)
 	seq_puts(s, ")\n");
 
 	seq_printf(s, "IRQ              : %d\n",
-		qca->spi_dev->irq);
+		   qca->spi_dev->irq);
 	seq_printf(s, "INTR REQ         : %u\n",
-		qca->intr_req);
+		   qca->intr_req);
 	seq_printf(s, "INTR SVC         : %u\n",
-		qca->intr_svc);
+		   qca->intr_svc);
 
 	seq_printf(s, "SPI max speed    : %lu\n",
-		(unsigned long) qca->spi_dev->max_speed_hz);
+		   (unsigned long)qca->spi_dev->max_speed_hz);
 	seq_printf(s, "SPI mode         : %x\n",
-		qca->spi_dev->mode);
+		   qca->spi_dev->mode);
 	seq_printf(s, "SPI chip select  : %u\n",
-		(unsigned int) qca->spi_dev->chip_select);
+		   (unsigned int)qca->spi_dev->chip_select);
 	seq_printf(s, "SPI legacy mode  : %u\n",
-		(unsigned int) qca->legacy_mode);
+		   (unsigned int)qca->legacy_mode);
 	seq_printf(s, "SPI burst length : %u\n",
-		(unsigned int) qca->burst_len);
+		   (unsigned int)qca->burst_len);
 
 	return 0;
 }
@@ -152,7 +152,7 @@ qcaspi_init_device_debugfs(struct qcaspi *qca)
 		return;
 	}
 	debugfs_create_file("info", S_IFREG | S_IRUGO, device_root, qca,
-			&qcaspi_info_ops);
+			    &qcaspi_info_ops);
 }
 
 void
@@ -215,7 +215,7 @@ qcaspi_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	switch (stringset) {
 	case ETH_SS_STATS:
 		memcpy(buf, &qcaspi_gstrings_stats,
-			sizeof(qcaspi_gstrings_stats));
+		       sizeof(qcaspi_gstrings_stats));
 		break;
 	default:
 		WARN_ON(1);
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.c b/drivers/net/ethernet/qualcomm/qca_framing.c
index 3c8d8d4..9bf2f19 100644
--- a/drivers/net/ethernet/qualcomm/qca_framing.c
+++ b/drivers/net/ethernet/qualcomm/qca_framing.c
@@ -152,4 +152,3 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 
 	return ret;
 }
-
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 30d8e23..42ff580 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -88,9 +88,9 @@ void
 end_spi_intr_handling(struct qcaspi *qca, u16 intr_cause)
 {
 	u16 intr_enable = (SPI_INT_CPU_ON |
-			SPI_INT_PKT_AVLBL |
-			SPI_INT_RDBUF_ERR |
-			SPI_INT_WRBUF_ERR);
+			   SPI_INT_PKT_AVLBL |
+			   SPI_INT_RDBUF_ERR |
+			   SPI_INT_WRBUF_ERR);
 
 	qcaspi_write_register(qca, SPI_REG_INTR_CAUSE, intr_cause);
 	qcaspi_write_register(qca, SPI_REG_INTR_ENABLE, intr_enable);
@@ -215,10 +215,10 @@ qcaspi_tx_frame(struct qcaspi *qca, struct sk_buff *skb)
 
 		if (qca->legacy_mode) {
 			bytes_written = qcaspi_write_legacy(qca,
-					skb->data + offset, count);
+							    skb->data + offset, count);
 		} else {
 			bytes_written = qcaspi_write_burst(qca,
-					skb->data + offset, count);
+							   skb->data + offset, count);
 		}
 
 		if (bytes_written != count)
@@ -296,7 +296,7 @@ qcaspi_receive(struct qcaspi *qca)
 	/* Allocate rx SKB if we don't have one available. */
 	if (!qca->rx_skb) {
 		qca->rx_skb = netdev_alloc_skb(qca->net_dev,
-				qca->net_dev->mtu + VLAN_ETH_HLEN);
+					       qca->net_dev->mtu + VLAN_ETH_HLEN);
 		if (!qca->rx_skb) {
 			netdev_dbg(qca->net_dev, "out of RX resources\n");
 			qca->stats.out_of_mem++;
@@ -307,7 +307,7 @@ qcaspi_receive(struct qcaspi *qca)
 	/* Read the packet size. */
 	qcaspi_read_register(qca, SPI_REG_RDBUF_BYTE_AVA, &available);
 	netdev_dbg(qca->net_dev, "qcaspi_receive: SPI_REG_RDBUF_BYTE_AVA: Value: %08x\n",
-			available);
+		   available);
 
 	if (available == 0) {
 		netdev_dbg(qca->net_dev, "qcaspi_receive called without any data being available!\n");
@@ -326,16 +326,16 @@ qcaspi_receive(struct qcaspi *qca)
 
 		if (qca->legacy_mode) {
 			bytes_read = qcaspi_read_legacy(qca, qca->rx_buffer,
-					count);
+							count);
 		} else {
 			bytes_read = qcaspi_read_burst(qca, qca->rx_buffer,
-					count);
+						       count);
 		}
 
 		cp = qca->rx_buffer;
 
 		netdev_dbg(qca->net_dev, "available: %d, byte read: %d\n",
-				available, bytes_read);
+			   available, bytes_read);
 
 		if (bytes_read)
 			available -= bytes_read;
@@ -346,9 +346,9 @@ qcaspi_receive(struct qcaspi *qca)
 			s32 retcode;
 
 			retcode = qcafrm_fsm_decode(&qca->frm_handle,
-					qca->rx_skb->data,
-					skb_tailroom(qca->rx_skb),
-					*cp);
+						    qca->rx_skb->data,
+						    skb_tailroom(qca->rx_skb),
+						    *cp);
 			cp++;
 			switch (retcode) {
 			case QCAFRM_GATHER:
@@ -374,7 +374,7 @@ qcaspi_receive(struct qcaspi *qca)
 				qca->rx_skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_rx_ni(qca->rx_skb);
 				qca->rx_skb = netdev_alloc_skb(qca->net_dev,
-					qca->net_dev->mtu + VLAN_ETH_HLEN);
+							       qca->net_dev->mtu + VLAN_ETH_HLEN);
 				if (!qca->rx_skb) {
 					netdev_dbg(qca->net_dev, "out of RX resources\n");
 					n_stats->rx_errors++;
@@ -443,7 +443,7 @@ qcaspi_qca7k_sync(struct qcaspi *qca, int event)
 		} else {
 			/* ensure that the WRBUF is empty */
 			qcaspi_read_register(qca, SPI_REG_WRBUF_SPC_AVA,
-				&wrbuf_space);
+					     &wrbuf_space);
 			if (wrbuf_space != QCASPI_HW_BUF_LEN) {
 				netdev_dbg(qca->net_dev, "sync: got CPU on, but wrbuf not empty. reset!\n");
 				qca->sync = QCASPI_SYNC_UNKNOWN;
@@ -487,7 +487,7 @@ qcaspi_qca7k_sync(struct qcaspi *qca, int event)
 	case QCASPI_SYNC_RESET:
 		reset_count++;
 		netdev_dbg(qca->net_dev, "sync: waiting for CPU on, count %u.\n",
-				reset_count);
+			   reset_count);
 		if (reset_count >= QCASPI_RESET_TIMEOUT) {
 			/* reset did not seem to take place, try again */
 			qca->sync = QCASPI_SYNC_UNKNOWN;
@@ -501,7 +501,7 @@ qcaspi_qca7k_sync(struct qcaspi *qca, int event)
 static int
 qcaspi_spi_thread(void *data)
 {
-	struct qcaspi *qca = (struct qcaspi *) data;
+	struct qcaspi *qca = data;
 	u16 intr_cause = 0;
 
 	netdev_info(qca->net_dev, "SPI thread created\n");
@@ -515,14 +515,14 @@ qcaspi_spi_thread(void *data)
 		set_current_state(TASK_RUNNING);
 
 		netdev_dbg(qca->net_dev, "have work to do. int: %d, tx_skb: %p\n",
-				qca->intr_req - qca->intr_svc,
-				qca->txr.skb[qca->txr.head]);
+			   qca->intr_req - qca->intr_svc,
+			   qca->txr.skb[qca->txr.head]);
 
 		qcaspi_qca7k_sync(qca, QCASPI_EVENT_UPDATE);
 
 		if (qca->sync != QCASPI_SYNC_READY) {
 			netdev_dbg(qca->net_dev, "sync: not ready %u, turn off carrier and flush\n",
-					(unsigned int) qca->sync);
+				   (unsigned int)qca->sync);
 			netif_stop_queue(qca->net_dev);
 			netif_carrier_off(qca->net_dev);
 			qcaspi_flush_tx_ring(qca);
@@ -584,10 +584,11 @@ qcaspi_spi_thread(void *data)
 static irqreturn_t
 qcaspi_intr_handler(int irq, void *data)
 {
-	struct qcaspi *qca = (struct qcaspi *) data;
+	struct qcaspi *qca = data;
+
 	qca->intr_req++;
 	if (qca->spi_thread &&
-		qca->spi_thread->state != TASK_RUNNING)
+	    qca->spi_thread->state != TASK_RUNNING)
 		wake_up_process(qca->spi_thread);
 
 	return IRQ_HANDLED;
@@ -608,19 +609,19 @@ qcaspi_netdev_open(struct net_device *dev)
 	qcafrm_fsm_init(&qca->frm_handle);
 
 	qca->spi_thread = kthread_run((void *)qcaspi_spi_thread,
-			qca, "%s", dev->name);
+				      qca, "%s", dev->name);
 
 	if (IS_ERR(qca->spi_thread)) {
 		netdev_err(dev, "%s: unable to start kernel thread.\n",
-				QCASPI_DRV_NAME);
+			   QCASPI_DRV_NAME);
 		return PTR_ERR(qca->spi_thread);
 	}
 
 	ret = request_irq(qca->spi_dev->irq, qcaspi_intr_handler, 0,
-			dev->name, qca);
+			  dev->name, qca);
 	if (ret) {
 		netdev_err(dev, "%s: unable to get IRQ %d (irqval=%d).\n",
-				QCASPI_DRV_NAME, qca->spi_dev->irq, ret);
+			   QCASPI_DRV_NAME, qca->spi_dev->irq, ret);
 		kthread_stop(qca->spi_thread);
 		return ret;
 	}
@@ -670,7 +671,7 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((skb_headroom(skb) < QCAFRM_HEADER_LEN) ||
 	    (skb_tailroom(skb) < QCAFRM_FOOTER_LEN + pad_len)) {
 		tskb = skb_copy_expand(skb, QCAFRM_HEADER_LEN,
-				QCAFRM_FOOTER_LEN + pad_len, GFP_ATOMIC);
+				       QCAFRM_FOOTER_LEN + pad_len, GFP_ATOMIC);
 		if (!tskb) {
 			netdev_dbg(qca->net_dev, "could not allocate tx_buff\n");
 			qca->stats.out_of_mem++;
@@ -694,7 +695,7 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	qcafrm_create_footer(ptmp);
 
 	netdev_dbg(qca->net_dev, "Tx-ing packet: Size: 0x%08x\n",
-			skb->len);
+		   skb->len);
 
 	qca->txr.size += skb->len + QCASPI_HW_PKT_LEN;
 
@@ -713,7 +714,7 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	if (qca->spi_thread &&
-		qca->spi_thread->state != TASK_RUNNING)
+	    qca->spi_thread->state != TASK_RUNNING)
 		wake_up_process(qca->spi_thread);
 
 	return NETDEV_TX_OK;
@@ -723,8 +724,9 @@ void
 qcaspi_netdev_tx_timeout(struct net_device *dev)
 {
 	struct qcaspi *qca = netdev_priv(dev);
+
 	netdev_info(qca->net_dev, "Transmit timeout at %ld, latency %ld\n",
-			jiffies, jiffies - dev->trans_start);
+		    jiffies, jiffies - dev->trans_start);
 	qca->net_dev->stats.tx_errors++;
 	/* wake the queue if there is room */
 	if (qcaspi_tx_ring_has_space(&qca->txr))
@@ -742,7 +744,7 @@ qcaspi_netdev_init(struct net_device *dev)
 	qca->burst_len = qcaspi_burst_len;
 	qca->spi_thread = NULL;
 	qca->buffer_size = (dev->mtu + VLAN_ETH_HLEN + QCAFRM_HEADER_LEN +
-		QCAFRM_FOOTER_LEN + 4) * 4;
+			    QCAFRM_FOOTER_LEN + 4) * 4;
 
 	memset(&qca->stats, 0, sizeof(struct qcaspi_stats));
 
@@ -764,6 +766,7 @@ static void
 qcaspi_netdev_uninit(struct net_device *dev)
 {
 	struct qcaspi *qca = netdev_priv(dev);
+
 	kfree(qca->rx_buffer);
 	qca->buffer_size = 0;
 	if (qca->rx_skb)
@@ -859,13 +862,13 @@ qca_spi_probe(struct spi_device *spi_device)
 	}
 
 	if (of_find_property(spi_device->dev.of_node,
-		"qca,legacy-mode", NULL)) {
+			     "qca,legacy-mode", NULL)) {
 		legacy_mode = 1;
 	}
 
 	if (qcaspi_clkspeed == 0) {
 		if (of_find_property(spi_device->dev.of_node,
-					"spi-max-frequency", NULL)) {
+				     "spi-max-frequency", NULL)) {
 			qcaspi_clkspeed = spi_device->max_speed_hz;
 		} else {
 			qcaspi_clkspeed = QCASPI_CLK_SPEED;
@@ -875,29 +878,29 @@ qca_spi_probe(struct spi_device *spi_device)
 	if ((qcaspi_clkspeed < QCASPI_CLK_SPEED_MIN) ||
 	    (qcaspi_clkspeed > QCASPI_CLK_SPEED_MAX)) {
 		dev_info(&spi_device->dev, "Invalid clkspeed: %d\n",
-			qcaspi_clkspeed);
+			 qcaspi_clkspeed);
 		return -EINVAL;
 	}
 
 	if ((qcaspi_burst_len < QCASPI_BURST_LEN_MIN) ||
 	    (qcaspi_burst_len > QCASPI_BURST_LEN_MAX)) {
 		dev_info(&spi_device->dev, "Invalid burst len: %d\n",
-			qcaspi_burst_len);
+			 qcaspi_burst_len);
 		return -EINVAL;
 	}
 
 	if ((qcaspi_pluggable < QCASPI_PLUGGABLE_MIN) ||
 	    (qcaspi_pluggable > QCASPI_PLUGGABLE_MAX)) {
 		dev_info(&spi_device->dev, "Invalid pluggable: %d\n",
-			qcaspi_pluggable);
+			 qcaspi_pluggable);
 		return -EINVAL;
 	}
 
 	dev_info(&spi_device->dev, "ver=%s, clkspeed=%d, burst_len=%d, pluggable=%d\n",
-		QCASPI_DRV_VERSION,
-		qcaspi_clkspeed,
-		qcaspi_burst_len,
-		qcaspi_pluggable);
+		 QCASPI_DRV_VERSION,
+		 qcaspi_clkspeed,
+		 qcaspi_burst_len,
+		 qcaspi_pluggable);
 
 	spi_device->mode = SPI_MODE_3;
 	spi_device->max_speed_hz = qcaspi_clkspeed;
@@ -930,7 +933,7 @@ qca_spi_probe(struct spi_device *spi_device)
 	if (!is_valid_ether_addr(qca->net_dev->dev_addr)) {
 		eth_hw_addr_random(qca->net_dev);
 		dev_info(&spi_device->dev, "Using random MAC address: %pM\n",
-			qca->net_dev->dev_addr);
+			 qca->net_dev->dev_addr);
 	}
 
 	netif_carrier_off(qca->net_dev);
@@ -949,7 +952,7 @@ qca_spi_probe(struct spi_device *spi_device)
 
 	if (register_netdev(qcaspi_devs)) {
 		dev_info(&spi_device->dev, "Unable to register net device %s\n",
-			qcaspi_devs->name);
+			 qcaspi_devs->name);
 		free_netdev(qcaspi_devs);
 		return -EFAULT;
 	}
@@ -998,4 +1001,3 @@ MODULE_AUTHOR("Qualcomm Atheros Communications");
 MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(QCASPI_DRV_VERSION);
-
