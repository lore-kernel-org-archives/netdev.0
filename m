From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ftmac100: use resource_size()
Date: Sat, 19 Mar 2011 07:39:15 +0300
Message-ID: <20110319043915.GB2008@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Po-Yu Chuang <ratbert@faraday-tech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62056 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab1CSEje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 00:39:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calculation is off-by-one.  It should be "end - start + 1".  This
patch fixes it to use resource_size() instead.  Oddly, the code already
uses resource size correctly a couple lines earlier when it calls
request_mem_region() for this memory.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
index 1d6f4b8..a316619 100644
--- a/drivers/net/ftmac100.c
+++ b/drivers/net/ftmac100.c
@@ -1102,7 +1102,7 @@ static int ftmac100_probe(struct platform_device *pdev)
 		goto err_req_mem;
 	}
 
-	priv->base = ioremap(res->start, res->end - res->start);
+	priv->base = ioremap(res->start, resource_size(res));
 	if (!priv->base) {
 		dev_err(&pdev->dev, "Failed to ioremap ethernet registers\n");
 		err = -EIO;
