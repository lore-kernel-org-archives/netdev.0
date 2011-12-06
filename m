From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 1/4] caif-hsi: Remove wake line modification when flushing FIFO
Date: Tue,  6 Dec 2011 23:15:41 +0100
Message-ID: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Auby <christian.auby@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62580 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753886Ab1LFWPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:15:55 -0500
Received: by lagp5 with SMTP id p5so1832667lag.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 14:15:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Christian Auby <christian.auby@stericsson.com>

Raising wake before flushing FIFO and lowering it after caused a
spike on AC wake that were sometimes detected and acted upon by the
modem. Fixed this by remove wake line modification when flushing FIFO.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 0733525..a85b29e 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -117,15 +117,6 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
 		__func__);
=20
-
-	ret =3D cfhsi->dev->cfhsi_wake_up(cfhsi->dev);
-	if (ret) {
-		dev_warn(&cfhsi->ndev->dev,
-			"%s: can't wake up HSI interface: %d.\n",
-			__func__, ret);
-		return ret;
-	}
-
 	do {
 		ret =3D cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
 				&fifo_occupancy);
@@ -168,8 +159,6 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 		}
 	} while (1);
=20
-	cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
-
 	return ret;
 }
=20
--=20
1.7.0.4
