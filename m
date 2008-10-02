From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: include linux/ip.h to fix build
Date: Thu, 2 Oct 2008 12:52:39 +0200
Message-ID: <20081002105239.GA31409@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:53890 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbYJBKwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 06:52:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv643xx_eth uses ip_hdr() (defined in linux/ip.h), but relied on
another header file to include the needed header file indirectly.
In latest net-next this indirect include chain is gone, so the
driver fails to build.  Include linux/ip.h explicitly to fix this.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 372811a..66e1878 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -38,6 +38,7 @@
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/in.h>
+#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/etherdevice.h>
