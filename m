From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/3] netdev: Remove SIOCDEVPRIVATE aliases for MDIO ioctls
Date: Thu, 03 Sep 2009 21:38:33 +0100
Message-ID: <1252010313.2781.14.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:49357 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752384AbZICUid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 16:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The standard MDIO ioctl numbers are well-established and these should
no longer be needed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ibm_newemac/core.c |    3 ---
 drivers/net/natsemi.c          |    3 ---
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index d7579e4..24ae671 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2218,16 +2218,13 @@ static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
-	case SIOCDEVPRIVATE:
 		data[0] = dev->phy.address;
 		/* Fall through */
 	case SIOCGMIIREG:
-	case SIOCDEVPRIVATE + 1:
 		data[3] = emac_mdio_read(ndev, dev->phy.address, data[1]);
 		return 0;
 
 	case SIOCSMIIREG:
-	case SIOCDEVPRIVATE + 2:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		emac_mdio_write(ndev, dev->phy.address, data[1], data[2]);
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index bd41351..b52e5d9 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -3053,12 +3053,10 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	switch(cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
-	case SIOCDEVPRIVATE:		/* for binary compat, remove in 2.5 */
 		data->phy_id = np->phy_addr_external;
 		/* Fall Through */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
-	case SIOCDEVPRIVATE+1:		/* for binary compat, remove in 2.5 */
 		/* The phy_id is not enough to uniquely identify
 		 * the intended target. Therefore the command is sent to
 		 * the given mii on the current port.
@@ -3077,7 +3075,6 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		return 0;
 
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-	case SIOCDEVPRIVATE+2:		/* for binary compat, remove in 2.5 */
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		if (dev->if_port == PORT_TP) {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

