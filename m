From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 2/3] caif-hsi: Free flip_buffer at shutdown
Date: Thu, 12 Apr 2012 20:18:08 +0200
Message-ID: <1334254689-2843-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:42120 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934579Ab2DLSSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:18:17 -0400
Received: by mail-lpp01m010-f46.google.com with SMTP id j13so1789545lah.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:18:17 -0700 (PDT)
In-Reply-To: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix memory leak of RX flip-buffer.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 9a66e2a..d0d9a6f 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1210,7 +1210,7 @@ int cfhsi_probe(struct platform_device *pdev)
=20
 static void cfhsi_shutdown(struct cfhsi *cfhsi)
 {
-	u8 *tx_buf, *rx_buf;
+	u8 *tx_buf, *rx_buf, *flip_buf;
=20
 	/* Stop TXing */
 	netif_tx_stop_all_queues(cfhsi->ndev);
@@ -1234,7 +1234,7 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi)
 	/* Store bufferes: will be freed later. */
 	tx_buf =3D cfhsi->tx_buf;
 	rx_buf =3D cfhsi->rx_buf;
-
+	flip_buf =3D cfhsi->rx_flip_buf;
 	/* Flush transmit queues. */
 	cfhsi_abort_tx(cfhsi);
=20
@@ -1247,6 +1247,7 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi)
 	/* Free buffers. */
 	kfree(tx_buf);
 	kfree(rx_buf);
+	kfree(flip_buf);
 }
=20
 int cfhsi_remove(struct platform_device *pdev)
--=20
1.7.5.4
