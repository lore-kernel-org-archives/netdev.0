From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/16] sfc: Remove overly paranoid locking
 assertions from netdev operations
Date: Fri, 24 Aug 2012 20:52:41 +0100
Message-ID: <1345837961.2694.35.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56831 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760132Ab2HXTwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:52:44 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c     |    8 --------
 drivers/net/ethernet/sfc/ethtool.c |    2 --
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index d065340..b29db12 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1767,8 +1767,6 @@ static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 
-	EFX_ASSERT_RESET_SERIALISED(efx);
-
 	/* Convert phy_id from older PRTAD/DEVAD format */
 	if ((cmd == SIOCGMIIREG || cmd == SIOCSMIIREG) &&
 	    (data->phy_id & 0xfc00) == 0x0400)
@@ -1850,8 +1848,6 @@ static int efx_net_open(struct net_device *net_dev)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
 
-	EFX_ASSERT_RESET_SERIALISED(efx);
-
 	netif_dbg(efx, ifup, efx->net_dev, "opening device on CPU %d\n",
 		  raw_smp_processor_id());
 
@@ -1946,8 +1942,6 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
 
-	EFX_ASSERT_RESET_SERIALISED(efx);
-
 	rc = efx_check_disabled(efx);
 	if (rc)
 		return rc;
@@ -1975,8 +1969,6 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	struct sockaddr *addr = data;
 	char *new_addr = addr->sa_data;
 
-	EFX_ASSERT_RESET_SERIALISED(efx);
-
 	if (!is_valid_ether_addr(new_addr)) {
 		netif_err(efx, drv, efx->net_dev,
 			  "invalid ethernet MAC address requested: %pM\n",
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 5d0e2a3..2bd5c2d 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -529,8 +529,6 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 	if (!efx_tests)
 		goto fail;
 
-
-	ASSERT_RTNL();
 	if (efx->state != STATE_READY) {
 		rc = -EIO;
 		goto fail1;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
