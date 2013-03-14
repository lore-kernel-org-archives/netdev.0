From: Georg Hofmann <georg@hofmannsweb.com>
Subject: [PATCH 3.9-rc2] net: fec: fix missing napi_disable call
Date: Thu, 14 Mar 2013 17:54:09 +0100
Message-ID: <1363280049.3967.21.camel@gh-dell>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpy94-2-81-56-63-32.fbx.proxad.net ([81.56.63.32]:37380 "EHLO
	hofmannsweb.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab3CNRBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 13:01:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit dc975382d2ef36be7e78fac3717927de1a5abcd8 introduces napi support
but never calls napi_disable. This will generate a kernel oops
(kernel BUG at include/linux/netdevice.h:473!) every time, when
ndo_stop is called followed by ndo_start.
Add the missing napi_diable call.

Signed-off-by: Georg Hofmann <georg@hofmannsweb.com>
---
 Tested with a imx28-evk board. 

 drivers/net/ethernet/freescale/fec.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 069a155..128da16 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1437,6 +1437,7 @@ fec_enet_close(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
 	/* Don't know what to do yet. */
+	napi_disable(&fep->napi);
 	fep->opened = 0;
 	netif_stop_queue(ndev);
 	fec_stop(ndev);
