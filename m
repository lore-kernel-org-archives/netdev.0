From: Dan Carpenter <error27@gmail.com>
Subject: [patch] skfp: testing the wrong variable in skfp_driver_init()
Date: Fri, 24 Dec 2010 08:17:34 +0300
Message-ID: <20101224051734.GO1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44229 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab0LXFRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Dec 2010 00:17:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent here was to test if the allocation failed but we tested 
"SharedMemSize" instead of "SharedMemAddr" by mistake.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 0a66fed..16c6265 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -412,7 +412,7 @@ static  int skfp_driver_init(struct net_device *dev)
 		bp->SharedMemAddr = pci_alloc_consistent(&bp->pdev,
 							 bp->SharedMemSize,
 							 &bp->SharedMemDMA);
-		if (!bp->SharedMemSize) {
+		if (!bp->SharedMemAddr) {
 			printk("could not allocate mem for ");
 			printk("hardware module: %ld byte\n",
 			       bp->SharedMemSize);
