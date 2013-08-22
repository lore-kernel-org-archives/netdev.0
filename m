From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH] net: fec: add the initial to set the physical mac
 address
Date: Thu, 22 Aug 2013 14:07:53 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F908B16A25@039-SN1MPN1-002.039d.mgd.msft.net>
References: <1377170269-8988-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	Zhou Luwei-B45643 <B45643@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:45677
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752560Ab3HVOIS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 10:08:18 -0400
In-Reply-To: <1377170269-8988-1-git-send-email-B38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I remember community have patch to set random mac if there are not validate mac address 

-----Original Message-----
From: Duan Fugang-B38611 
Sent: Thursday, August 22, 2013 6:18 AM
To: Li Frank-B20596; Zhou Luwei-B45643; davem@davemloft.net
Cc: netdev@vger.kernel.org; shawn.guo@linaro.org; bhutchings@solarflare.com; Estevam Fabio-R49496; stephen@networkplumber.org
Subject: [PATCH] net: fec: add the initial to set the physical mac address

For imx6slx evk platform, the fec driver cannot work since there have no valid mac address set in physical mac registers.

For imx serial platform, fec/enet IPs both need the physical MAC address initial, otherwise it cannot work.

After acquiring the valid MAC address from devices tree/pfuse/ kernel command line/random mac address, and then set it to the physical MAC address registers.

Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4349a9e..9b5e08c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1867,10 +1867,12 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+	if (p) {
+		if (!is_valid_ether_addr(addr->sa_data))
+			return -EADDRNOTAVAIL;
 
-	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+	}
 
 	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
 		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24), @@ -1969,6 +1971,7 @@ static int fec_enet_init(struct net_device *ndev)
 
 	/* Get the Ethernet address */
 	fec_get_mac(ndev);
+	fec_set_mac_address(ndev, NULL);
 
 	/* Set receive and transmit descriptor base. */
 	fep->rx_bd_base = cbd_base;
--
1.7.1
