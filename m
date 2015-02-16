From: Vlastimil Setka <setka@vsis.cz>
Subject: Re: Altera TSE (altera_tse) - tx_fifo_depth init bug
Date: Mon, 16 Feb 2015 23:43:15 +0100
Message-ID: <54E27283.3020201@vsis.cz>
References: <54C8026B.9070607@vsis.cz> <20150129.142250.2177840872104162590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridger@opensource.altera.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.spsostrov.cz ([217.117.209.230]:55984 "EHLO
	mail.spsostrov.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbbBPWnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 17:43:23 -0500
In-Reply-To: <20150129.142250.2177840872104162590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Your patch was corrupted by your email client, in particular TAB
> characters were transformed into a series of SPACE characters.

Hello,
sorry for inconvenience, here is a correct patch:

[PATCH 1/1] Altera TSE: Fix priv->tx_fifo_depth initialization

This patch fixes priv->tx_fifo_depth initialization in altera_tse_probe().
The "tx-fifo-depth" attribute was read again into rx_fifo_depth instead of
correct tx_fifo_depth probably because of copy-and-paste typo,
and tx_fifo_depth was left uninitialised.

Signed-off-by: Vlastimil Setka <setka@vsis.cz>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 760c72c..f3d784a 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1399,7 +1399,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	}
 
 	if (of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
-				 &priv->rx_fifo_depth)) {
+				 &priv->tx_fifo_depth)) {
 		dev_err(&pdev->dev, "cannot obtain tx-fifo-depth\n");
 		ret = -ENXIO;
 		goto err_free_netdev;
--
1.8.1.2
