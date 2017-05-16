From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/9] nfp: don't enable TSO on the device when disabled
Date: Mon, 15 May 2017 17:55:15 -0700
Message-ID: <20170516005523.26124-2-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34489 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdEPA4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:19 -0400
Received: by mail-pf0-f171.google.com with SMTP id 9so31447662pfj.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:18 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We advertise TSO to the stack but leave it disabled by default.
Make sure it's not only disabled in the netdev features but
also on the device itself.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 82bd6b0935f1..76251a09a1f3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3286,6 +3286,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	/* Advertise but disable TSO by default. */
 	netdev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+	nn->dp.ctrl &= ~NFP_NET_CFG_CTRL_LSO;
 
 	/* Allow L2 Broadcast and Multicast through by default, if supported */
 	if (nn->cap & NFP_NET_CFG_CTRL_L2BC)
-- 
2.11.0
