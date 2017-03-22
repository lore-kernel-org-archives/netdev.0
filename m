From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 14/15] nfp: remove defensive checks around ndo_open()/ndo_close()
Date: Tue, 21 Mar 2017 17:59:20 -0700
Message-ID: <20170322005921.10965-15-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36263 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758524AbdCVBGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:06:35 -0400
Received: by mail-pg0-f41.google.com with SMTP id g2so100789976pge.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:06:34 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device open and close handlers check if the device is already
in the desired state.  Thanks to our reconfig infrastructure
this should not be necessary, there doesn't seem to be any
code in the driver which depends on it.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index d35eeba86bac..e12353a7c83c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2233,11 +2233,6 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err, r;
 
-	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_ENABLE) {
-		nn_err(nn, "Dev is already enabled: 0x%08x\n", nn->dp.ctrl);
-		return -EBUSY;
-	}
-
 	/* Step 1: Allocate resources for rings and the like
 	 * - Request interrupts
 	 * - Allocate RX and TX ring resources
@@ -2368,11 +2363,6 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (!(nn->dp.ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
-		nn_err(nn, "Dev is not up: 0x%08x\n", nn->dp.ctrl);
-		return 0;
-	}
-
 	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
 	 */
 	nfp_net_close_stack(nn);
-- 
2.11.0
