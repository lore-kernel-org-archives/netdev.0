From: sjur.brandeland@stericsson.com
Subject: [net-next 06/11] caif-hsi: Use netdev_X instead of dev_X for printing
Date: Mon, 25 Jun 2012 19:49:38 +0200
Message-ID: <1340646583-21059-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?=
	<sjur.brandeland@stericssion.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57421 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409Ab2FYRuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:02 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so3429750bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:50:01 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Replace dev_X with the corresponding netdev_X print
function when applicable.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericssion.com>
---
 drivers/net/caif/caif_hsi.c |   94 +++++++++++++++++++++--------------=
-------
 1 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 56cc941..f7997a7 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -85,7 +85,7 @@ static void cfhsi_inactivity_tout(unsigned long arg)
 {
 	struct cfhsi *cfhsi =3D (struct cfhsi *)arg;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	/* Schedule power down work queue. */
@@ -181,14 +181,14 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 	size_t fifo_occupancy;
 	int ret;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	do {
 		ret =3D cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
 				&fifo_occupancy);
 		if (ret) {
-			dev_warn(&cfhsi->ndev->dev,
+			netdev_warn(cfhsi->ndev,
 				"%s: can't get FIFO occupancy: %d.\n",
 				__func__, ret);
 			break;
@@ -202,7 +202,7 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 				cfhsi->dev);
 		if (ret) {
 			clear_bit(CFHSI_FLUSH_FIFO, &cfhsi->bits);
-			dev_warn(&cfhsi->ndev->dev,
+			netdev_warn(cfhsi->ndev,
 				"%s: can't read data: %d.\n",
 				__func__, ret);
 			break;
@@ -213,13 +213,13 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 			 !test_bit(CFHSI_FLUSH_FIFO, &cfhsi->bits), ret);
=20
 		if (ret < 0) {
-			dev_warn(&cfhsi->ndev->dev,
+			netdev_warn(cfhsi->ndev,
 				"%s: can't wait for flush complete: %d.\n",
 				__func__, ret);
 			break;
 		} else if (!ret) {
 			ret =3D -ETIMEDOUT;
-			dev_warn(&cfhsi->ndev->dev,
+			netdev_warn(cfhsi->ndev,
 				"%s: timeout waiting for flush complete.\n",
 				__func__);
 			break;
@@ -348,7 +348,7 @@ static void cfhsi_start_tx(struct cfhsi *cfhsi)
 	struct cfhsi_desc *desc =3D (struct cfhsi_desc *)cfhsi->tx_buf;
 	int len, res;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
+	netdev_dbg(cfhsi->ndev, "%s.\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
@@ -374,14 +374,14 @@ static void cfhsi_start_tx(struct cfhsi *cfhsi)
 		/* Set up new transfer. */
 		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
 		if (WARN_ON(res < 0))
-			dev_err(&cfhsi->ndev->dev, "%s: TX error %d.\n",
+			netdev_err(cfhsi->ndev, "%s: TX error %d.\n",
 				__func__, res);
 	} while (res < 0);
 }
=20
 static void cfhsi_tx_done(struct cfhsi *cfhsi)
 {
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
+	netdev_dbg(cfhsi->ndev, "%s.\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
@@ -416,7 +416,7 @@ static void cfhsi_tx_done_cb(struct cfhsi_drv *drv)
 	struct cfhsi *cfhsi;
=20
 	cfhsi =3D container_of(drv, struct cfhsi, drv);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
@@ -433,7 +433,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
=20
 	if ((desc->header & ~CFHSI_PIGGY_DESC) ||
 			(desc->offset > CFHSI_MAX_EMB_FRM_SZ)) {
-		dev_err(&cfhsi->ndev->dev, "%s: Invalid descriptor.\n",
+		netdev_err(cfhsi->ndev, "%s: Invalid descriptor.\n",
 			__func__);
 		return -EPROTO;
 	}
@@ -455,7 +455,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
=20
 		/* Sanity check length of CAIF frame. */
 		if (unlikely(len > CFHSI_MAX_CAIF_FRAME_SZ)) {
-			dev_err(&cfhsi->ndev->dev, "%s: Invalid length.\n",
+			netdev_err(cfhsi->ndev, "%s: Invalid length.\n",
 				__func__);
 			return -EPROTO;
 		}
@@ -463,7 +463,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 		/* Allocate SKB (OK even in IRQ context). */
 		skb =3D alloc_skb(len + 1, GFP_ATOMIC);
 		if (!skb) {
-			dev_err(&cfhsi->ndev->dev, "%s: Out of memory !\n",
+			netdev_err(cfhsi->ndev, "%s: Out of memory !\n",
 				__func__);
 			return -ENOMEM;
 		}
@@ -504,7 +504,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 		xfer_sz +=3D CFHSI_DESC_SZ;
=20
 	if ((xfer_sz % 4) || (xfer_sz > (CFHSI_BUF_SZ_RX - CFHSI_DESC_SZ))) {
-		dev_err(&cfhsi->ndev->dev,
+		netdev_err(cfhsi->ndev,
 				"%s: Invalid payload len: %d, ignored.\n",
 			__func__, xfer_sz);
 		return -EPROTO;
@@ -551,7 +551,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 	/* Sanity check header and offset. */
 	if (WARN_ON((desc->header & ~CFHSI_PIGGY_DESC) ||
 			(desc->offset > CFHSI_MAX_EMB_FRM_SZ))) {
-		dev_err(&cfhsi->ndev->dev, "%s: Invalid descriptor.\n",
+		netdev_err(cfhsi->ndev, "%s: Invalid descriptor.\n",
 			__func__);
 		return -EPROTO;
 	}
@@ -585,7 +585,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
=20
 		/* Sanity check length of CAIF frames. */
 		if (unlikely(len > CFHSI_MAX_CAIF_FRAME_SZ)) {
-			dev_err(&cfhsi->ndev->dev, "%s: Invalid length.\n",
+			netdev_err(cfhsi->ndev, "%s: Invalid length.\n",
 				__func__);
 			return -EPROTO;
 		}
@@ -593,7 +593,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 		/* Allocate SKB (OK even in IRQ context). */
 		skb =3D alloc_skb(len + 1, GFP_ATOMIC);
 		if (!skb) {
-			dev_err(&cfhsi->ndev->dev, "%s: Out of memory !\n",
+			netdev_err(cfhsi->ndev, "%s: Out of memory !\n",
 				__func__);
 			cfhsi->rx_state.nfrms =3D nfrms;
 			return -ENOMEM;
@@ -639,7 +639,7 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
=20
 	desc =3D (struct cfhsi_desc *)cfhsi->rx_buf;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s\n", __func__);
+	netdev_dbg(cfhsi->ndev, "%s\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
@@ -709,13 +709,13 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 	/* Initiate next read */
 	if (test_bit(CFHSI_AWAKE, &cfhsi->bits)) {
 		/* Set up new transfer. */
-		dev_dbg(&cfhsi->ndev->dev, "%s: Start RX.\n",
+		netdev_dbg(cfhsi->ndev, "%s: Start RX.\n",
 				__func__);
=20
 		res =3D cfhsi->dev->cfhsi_rx(rx_ptr, rx_len,
 				cfhsi->dev);
 		if (WARN_ON(res < 0)) {
-			dev_err(&cfhsi->ndev->dev, "%s: RX error %d.\n",
+			netdev_err(cfhsi->ndev, "%s: RX error %d.\n",
 				__func__, res);
 			cfhsi->ndev->stats.rx_errors++;
 			cfhsi->ndev->stats.rx_dropped++;
@@ -750,7 +750,7 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 	return;
=20
 out_of_sync:
-	dev_err(&cfhsi->ndev->dev, "%s: Out of sync.\n", __func__);
+	netdev_err(cfhsi->ndev, "%s: Out of sync.\n", __func__);
 	print_hex_dump_bytes("--> ", DUMP_PREFIX_NONE,
 			cfhsi->rx_buf, CFHSI_DESC_SZ);
 	schedule_work(&cfhsi->out_of_sync_work);
@@ -760,7 +760,7 @@ static void cfhsi_rx_slowpath(unsigned long arg)
 {
 	struct cfhsi *cfhsi =3D (struct cfhsi *)arg;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	cfhsi_rx_done(cfhsi);
@@ -771,7 +771,7 @@ static void cfhsi_rx_done_cb(struct cfhsi_drv *drv)
 	struct cfhsi *cfhsi;
=20
 	cfhsi =3D container_of(drv, struct cfhsi, drv);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
@@ -806,7 +806,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 	/* Activate wake line. */
 	cfhsi->dev->cfhsi_wake_up(cfhsi->dev);
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s: Start waiting.\n",
+	netdev_dbg(cfhsi->ndev, "%s: Start waiting.\n",
 		__func__);
=20
 	/* Wait for acknowledge. */
@@ -816,7 +816,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 							&cfhsi->bits), ret);
 	if (unlikely(ret < 0)) {
 		/* Interrupted by signal. */
-		dev_err(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
+		netdev_err(cfhsi->ndev, "%s: Signalled: %ld.\n",
 			__func__, ret);
=20
 		clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
@@ -827,14 +827,14 @@ static void cfhsi_wake_up(struct work_struct *wor=
k)
 		size_t fifo_occupancy =3D 0;
=20
 		/* Wakeup timeout */
-		dev_dbg(&cfhsi->ndev->dev, "%s: Timeout.\n",
+		netdev_dbg(cfhsi->ndev, "%s: Timeout.\n",
 			__func__);
=20
 		/* Check FIFO to check if modem has sent something. */
 		WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
 					&fifo_occupancy));
=20
-		dev_dbg(&cfhsi->ndev->dev, "%s: Bytes in FIFO: %u.\n",
+		netdev_dbg(cfhsi->ndev, "%s: Bytes in FIFO: %u.\n",
 				__func__, (unsigned) fifo_occupancy);
=20
 		/* Check if we misssed the interrupt. */
@@ -842,7 +842,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 							&ca_wake));
=20
 		if (ca_wake) {
-			dev_err(&cfhsi->ndev->dev, "%s: CA Wake missed !.\n",
+			netdev_err(cfhsi->ndev, "%s: CA Wake missed !.\n",
 				__func__);
=20
 			/* Clear the CFHSI_WAKE_UP_ACK bit to prevent race. */
@@ -857,7 +857,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 		return;
 	}
 wake_ack:
-	dev_dbg(&cfhsi->ndev->dev, "%s: Woken.\n",
+	netdev_dbg(cfhsi->ndev, "%s: Woken.\n",
 		__func__);
=20
 	/* Clear power up bit. */
@@ -865,11 +865,11 @@ wake_ack:
 	clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
=20
 	/* Resume read operation. */
-	dev_dbg(&cfhsi->ndev->dev, "%s: Start RX.\n", __func__);
+	netdev_dbg(cfhsi->ndev, "%s: Start RX.\n", __func__);
 	res =3D cfhsi->dev->cfhsi_rx(cfhsi->rx_ptr, cfhsi->rx_len, cfhsi->dev=
);
=20
 	if (WARN_ON(res < 0))
-		dev_err(&cfhsi->ndev->dev, "%s: RX err %d.\n", __func__, res);
+		netdev_err(cfhsi->ndev, "%s: RX err %d.\n", __func__, res);
=20
 	/* Clear power up acknowledment. */
 	clear_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
@@ -878,7 +878,7 @@ wake_ack:
=20
 	/* Resume transmit if queues are not empty. */
 	if (!cfhsi_tx_queue_len(cfhsi)) {
-		dev_dbg(&cfhsi->ndev->dev, "%s: Peer wake, start timer.\n",
+		netdev_dbg(cfhsi->ndev, "%s: Peer wake, start timer.\n",
 			__func__);
 		/* Start inactivity timer. */
 		mod_timer(&cfhsi->inactivity_timer,
@@ -887,7 +887,7 @@ wake_ack:
 		return;
 	}
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s: Host wake.\n",
+	netdev_dbg(cfhsi->ndev, "%s: Host wake.\n",
 		__func__);
=20
 	spin_unlock_bh(&cfhsi->lock);
@@ -899,12 +899,12 @@ wake_ack:
 		/* Set up new transfer. */
 		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
 		if (WARN_ON(res < 0)) {
-			dev_err(&cfhsi->ndev->dev, "%s: TX error %d.\n",
+			netdev_err(cfhsi->ndev, "%s: TX error %d.\n",
 				__func__, res);
 			cfhsi_abort_tx(cfhsi);
 		}
 	} else {
-		dev_err(&cfhsi->ndev->dev,
+		netdev_err(cfhsi->ndev,
 				"%s: Failed to create HSI frame: %d.\n",
 				__func__, len);
 	}
@@ -918,7 +918,7 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
 	int retry =3D CFHSI_WAKE_TOUT;
=20
 	cfhsi =3D container_of(work, struct cfhsi, wake_down_work);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
+	netdev_dbg(cfhsi->ndev, "%s.\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
@@ -933,20 +933,20 @@ static void cfhsi_wake_down(struct work_struct *w=
ork)
 							&cfhsi->bits), ret);
 	if (ret < 0) {
 		/* Interrupted by signal. */
-		dev_err(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
+		netdev_err(cfhsi->ndev, "%s: Signalled: %ld.\n",
 			__func__, ret);
 		return;
 	} else if (!ret) {
 		bool ca_wake =3D true;
=20
 		/* Timeout */
-		dev_err(&cfhsi->ndev->dev, "%s: Timeout.\n", __func__);
+		netdev_err(cfhsi->ndev, "%s: Timeout.\n", __func__);
=20
 		/* Check if we misssed the interrupt. */
 		WARN_ON(cfhsi->dev->cfhsi_get_peer_wake(cfhsi->dev,
 							&ca_wake));
 		if (!ca_wake)
-			dev_err(&cfhsi->ndev->dev, "%s: CA Wake missed !.\n",
+			netdev_err(cfhsi->ndev, "%s: CA Wake missed !.\n",
 				__func__);
 	}
=20
@@ -964,7 +964,7 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
 	}
=20
 	if (!retry)
-		dev_err(&cfhsi->ndev->dev, "%s: FIFO Timeout.\n", __func__);
+		netdev_err(cfhsi->ndev, "%s: FIFO Timeout.\n", __func__);
=20
 	/* Clear AWAKE condition. */
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);
@@ -990,7 +990,7 @@ static void cfhsi_wake_up_cb(struct cfhsi_drv *drv)
 	struct cfhsi *cfhsi =3D NULL;
=20
 	cfhsi =3D container_of(drv, struct cfhsi, drv);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	set_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
@@ -1009,7 +1009,7 @@ static void cfhsi_wake_down_cb(struct cfhsi_drv *=
drv)
 	struct cfhsi *cfhsi =3D NULL;
=20
 	cfhsi =3D container_of(drv, struct cfhsi, drv);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	/* Initiating low power is only permitted by the host (us). */
@@ -1021,7 +1021,7 @@ static void cfhsi_aggregation_tout(unsigned long =
arg)
 {
 	struct cfhsi *cfhsi =3D (struct cfhsi *)arg;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
 	cfhsi_start_tx(cfhsi);
@@ -1113,7 +1113,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struct=
 net_device *dev)
 		/* Set up new transfer. */
 		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
 		if (WARN_ON(res < 0)) {
-			dev_err(&cfhsi->ndev->dev, "%s: TX error %d.\n",
+			netdev_err(cfhsi->ndev, "%s: TX error %d.\n",
 				__func__, res);
 			cfhsi_abort_tx(cfhsi);
 		}
@@ -1269,7 +1269,7 @@ static int cfhsi_open(struct net_device *ndev)
 	/* Create work thread. */
 	cfhsi->wq =3D create_singlethread_workqueue(cfhsi->pdev->name);
 	if (!cfhsi->wq) {
-		dev_err(&cfhsi->ndev->dev, "%s: Failed to create work queue.\n",
+		netdev_err(cfhsi->ndev, "%s: Failed to create work queue.\n",
 			__func__);
 		res =3D -ENODEV;
 		goto err_create_wq;
@@ -1296,7 +1296,7 @@ static int cfhsi_open(struct net_device *ndev)
 	/* Activate HSI interface. */
 	res =3D cfhsi->dev->cfhsi_up(cfhsi->dev);
 	if (res) {
-		dev_err(&cfhsi->ndev->dev,
+		netdev_err(cfhsi->ndev,
 			"%s: can't activate HSI interface: %d.\n",
 			__func__, res);
 		goto err_activate;
@@ -1305,7 +1305,7 @@ static int cfhsi_open(struct net_device *ndev)
 	/* Flush FIFO */
 	res =3D cfhsi_flush_fifo(cfhsi);
 	if (res) {
-		dev_err(&cfhsi->ndev->dev, "%s: Can't flush FIFO: %d.\n",
+		netdev_err(cfhsi->ndev, "%s: Can't flush FIFO: %d.\n",
 			__func__, res);
 		goto err_net_reg;
 	}
--=20
1.7.5.4
