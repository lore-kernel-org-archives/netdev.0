From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] ethernet/sfc: use core min/max MTU checking
Date: Tue, 18 Oct 2016 17:47:45 +0100
Message-ID: <4705a2ea-7734-b549-561c-bc7b6d8710d3@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>,
        <netdev@vger.kernel.org>, Jarod Wilson <jarod@redhat.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:29302 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753901AbcJRQr4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 12:47:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 61e84623 ("net: centralize net_device min/max MTU checking")
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3cf3557..b626da6 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2263,18 +2263,6 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	rc = efx_check_disabled(efx);
 	if (rc)
 		return rc;
-	if (new_mtu > EFX_MAX_MTU) {
-		netif_err(efx, drv, efx->net_dev,
-			  "Requested MTU of %d too big (max: %d)\n",
-			  new_mtu, EFX_MAX_MTU);
-		return -EINVAL;
-	}
-	if (new_mtu < EFX_MIN_MTU) {
-		netif_err(efx, drv, efx->net_dev,
-			  "Requested MTU of %d too small (min: %d)\n",
-			  new_mtu, EFX_MIN_MTU);
-		return -EINVAL;
-	}
 
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
@@ -2478,6 +2466,8 @@ static int efx_register_netdev(struct efx_nic *efx)
 		net_dev->priv_flags |= IFF_UNICAST_FLT;
 	net_dev->ethtool_ops = &efx_ethtool_ops;
 	net_dev->gso_max_segs = EFX_TSO_MAX_SEGS;
+	net_dev->min_mtu = EFX_MIN_MTU;
+	net_dev->max_mtu = EFX_MAX_MTU;
 
 	rtnl_lock();
 
-- 
2.7.4
