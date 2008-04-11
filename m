From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH] fs_enet: Don't call NAPI functions when NAPI is not used.
Date: Fri, 11 Apr 2008 14:05:50 +0200
Message-ID: <200804111405.50896.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:35183 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbYDKMF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 08:05:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fs_enet_close() calls napi_disable() unconditionally. This patch skips the
call when use_napi isn't set.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
---
 drivers/net/fs_enet/fs_enet-main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index c83bd65..1801ce3 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -835,7 +835,8 @@ static int fs_enet_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
-	napi_disable(&fep->napi);
+	if (fep->fpi->use_napi)
+		napi_disable(&fep->napi);
 	phy_stop(fep->phydev);
 
 	spin_lock_irqsave(&fep->lock, flags);
-- 
1.5.0

This is a bugfix and should probably go in 2.6.25.

-- 
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
F +32 (2) 387 42 75
