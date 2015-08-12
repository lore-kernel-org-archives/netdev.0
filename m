From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] cosa: missing error code on failure in probe()
Date: Thu, 13 Aug 2015 00:08:01 +0300
Message-ID: <20150812210800.GB8068@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23886 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbbHLVIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:08:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If register_hdlc_device() fails, the current code returns 0 but we
should return an error code instead.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 7193b73..848ea6a 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -589,7 +589,8 @@ static int cosa_probe(int base, int irq, int dma)
 		chan->netdev->base_addr = chan->cosa->datareg;
 		chan->netdev->irq = chan->cosa->irq;
 		chan->netdev->dma = chan->cosa->dma;
-		if (register_hdlc_device(chan->netdev)) {
+		err = register_hdlc_device(chan->netdev);
+		if (err) {
 			netdev_warn(chan->netdev,
 				    "register_hdlc_device() failed\n");
 			free_netdev(chan->netdev);
