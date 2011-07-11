From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 05/46] net: bnx2x: fix DMA sync direction
Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
Message-ID: <50f6eeeabc97a88b8ea9ca9bdbdbed1bb0bdccb8.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43662 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882Ab1GKAwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:50 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bnx2x/bnx2x_cmn.c     |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index bb75560..4f9164c 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -658,7 +658,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int bud=
get)
 			/* non TPA */
 			len =3D le16_to_cpu(cqe_fp->pkt_len);
 			pad =3D cqe_fp->placement_offset;
-			dma_sync_single_for_device(&bp->pdev->dev,
+			dma_sync_single_for_cpu(&bp->pdev->dev,
 					dma_unmap_addr(rx_buf, mapping),
 						       pad + RX_COPY_THRESH,
 						       DMA_FROM_DEVICE);
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2=
x_ethtool.c
index 1a3ed41..9a98b83 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1751,7 +1751,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, i=
nt loopback_mode)
 		goto test_loopback_rx_exit;
=20
 	rx_buf =3D &fp_rx->rx_buf_ring[RX_BD(fp_rx->rx_bd_cons)];
-	dma_sync_single_for_device(&bp->pdev->dev,
+	dma_sync_single_for_cpu(&bp->pdev->dev,
 				   dma_unmap_addr(rx_buf, mapping),
 				   fp_rx->rx_buf_size, DMA_FROM_DEVICE);
 	skb =3D rx_buf->skb;
--=20
1.7.5.4

