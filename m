From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] ne2000: add the right platform device
Date: Tue, 20 Nov 2012 16:31:57 +0000
Message-ID: <20121120163157.11874.74810.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:60934 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab2KTQ3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 11:29:39 -0500
Received: from bob.linux.org.uk (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id qAKH1HYg002838
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 17:01:22 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Without this udev doesn't have a way to key the ne device to the platform
device.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/ethernet/8390/ne.c |    1 +
 1 file changed, 1 insertion(+)


diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index d04911d..47618e5 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -813,6 +813,7 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 		dev->irq = irq[this_dev];
 		dev->mem_end = bad[this_dev];
 	}
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	err = do_ne_probe(dev);
 	if (err) {
 		free_netdev(dev);
