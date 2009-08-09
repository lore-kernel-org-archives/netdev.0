From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/3] drivers/net: Correct use of request_region/request_mem_region
Date: Sun, 9 Aug 2009 09:43:42 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908090943210.13271@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:54878 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbZHIHno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 03:43:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

request_mem_region should be used with release_mem_region, not request_region.

The semantic patch that fixes this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r2@
expression start;
@@

request_mem_region(start,...)

@b2@
expression r2.start;
@@

request_region(start,...)

@depends on !b2@
expression r2.start;
expression E;
@@

- release_region
+ release_mem_region
  (start,E)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/jazzsonic.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -u -p a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -203,7 +203,7 @@ static int __devinit sonic_probe1(struct
 
 	return 0;
 out:
-	release_region(dev->base_addr, SONIC_MEM_SIZE);
+	release_mem_region(dev->base_addr, SONIC_MEM_SIZE);
 	return err;
 }
 
@@ -247,7 +247,7 @@ static int __devinit jazz_sonic_probe(st
 	return 0;
 
 out1:
-	release_region(dev->base_addr, SONIC_MEM_SIZE);
+	release_mem_region(dev->base_addr, SONIC_MEM_SIZE);
 out:
 	free_netdev(dev);
 
@@ -269,7 +269,7 @@ static int __devexit jazz_sonic_device_r
 	unregister_netdev(dev);
 	dma_free_coherent(lp->device, SIZEOF_SONIC_DESC * SONIC_BUS_SCALE(lp->dma_bitmode),
 	                  lp->descriptors, lp->descriptors_laddr);
-	release_region (dev->base_addr, SONIC_MEM_SIZE);
+	release_mem_region(dev->base_addr, SONIC_MEM_SIZE);
 	free_netdev(dev);
 
 	return 0;
