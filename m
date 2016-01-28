From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 27/40] net: fec: enable interrupt on very last descriptor only
Date: Thu, 28 Jan 2016 14:25:51 -0700
Message-ID: <1454016364-30985-28-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35371 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896AbcA1V2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:54 -0500
Received: by mail-pf0-f179.google.com with SMTP id 65so29729662pfd.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:54 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cf53e21..7258051 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -689,7 +689,8 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 							bdp, index,
 							tso.data, size,
 							size == data_left,
-							total_len == 0);
+							(total_len == 0) &&
+							(size == data_left));
 			if (ret)
 				goto err_release;
 
-- 
2.5.0
