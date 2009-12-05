From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: Re: [PATCH] net: Modify return value for the .ndo_set_mac_address
Date: Sat, 5 Dec 2009 22:29:26 +0300
Message-ID: <20091205192926.GA4031@coldcone>
References: <20091204114721.GA5505@coldcone>
 <20091204.133018.10228592.davem@davemloft.net>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:34451 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757942AbZLET1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 14:27:37 -0500
Received: by bwz27 with SMTP id 27so2675555bwz.21
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2009 11:27:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091204.133018.10228592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2009 at 13:30 -0800, David Miller wrote:
> From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
> Date: Fri, 4 Dec 2009 14:47:22 +0300
> 
> > Return -EADDRNOTAVAIL insted of -EINVAL in .ndo_set_mac_address.
> > 
> > Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
> 
> Why?
> 
> The address is "invalid" so we return "invalid" error.
> 
> What's the problem?
> 
> And whether there is a good reason or not, your commit message did not
> describe that reason so needs to be updated.

[PATCH] net: Modify return value for the .ndo_set_mac_address

Return -EADDRNOTAVAIL instead of -EINVAL in .ndo_set_mac_address.

Some drivers in drivers/net return -EINVAL in .ndo_set_mac_address,
but some -EADDRNOTAVAIL. Thus, we use
"Cannot assign requested address" in the case of setting up new hw address
to be more consistent across drivers/net in
.ndo_set_mac_address function.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

---
drivers/net/b44.c                    |    2 +-
 drivers/net/bnx2.c                   |    2 +-
 drivers/net/bnx2x_main.c             |    2 +-
 drivers/net/cxgb3/cxgb3_main.c       |    2 +-
 drivers/net/davinci_emac.c           |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 drivers/net/niu.c                    |    2 +-
 drivers/net/pasemi_mac.c             |    2 +-
 drivers/net/s2io.c                   |    2 +-
 drivers/net/sfc/efx.c                |    2 +-
 drivers/net/tsi108_eth.c             |    2 +-
 drivers/net/usb/dm9601.c             |    2 +-
 drivers/net/usb/mcs7830.c            |    2 +-
 drivers/net/vxge/vxge-main.c         |    2 +-
 14 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 2a91323..2f4877e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1363,7 +1363,7 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
 		return -EBUSY;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4bfc808..dd86477 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7594,7 +7594,7 @@ bnx2_change_mac_addr(struct net_device *dev, void *p)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev))
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 77ba135..b87509e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11582,7 +11582,7 @@ static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (!is_valid_ether_addr((u8 *)(addr->sa_data)))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev)) {
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index cef3f88..fda1dd6 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2523,7 +2523,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	t3_mac_set_address(&pi->mac, LAN_MAC_IDX, dev->dev_addr);
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 8edac89..cc78677 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1823,7 +1823,7 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	struct sockaddr *sa = addr;
 
 	if (!is_valid_ether_addr(sa->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	/* Store mac addr in priv and rx channel and set it in EMAC hw */
 	memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e5d187f..5d754ba 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -461,7 +461,7 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	if (netif_running(netdev)) {
 		netif_device_detach(netdev);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 8ce58c4..67d762c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6435,7 +6435,7 @@ static int niu_set_mac_addr(struct net_device *dev, void *p)
 	unsigned long flags;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 1673eb0..9a68ef2 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -236,7 +236,7 @@ static int pasemi_mac_set_mac_addr(struct net_device *dev, void *p)
 	unsigned int adr0, adr1;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 0dd7839..781e7bd 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5273,7 +5273,7 @@ static int s2io_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f983e3b..6893681 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1585,7 +1585,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	if (!is_valid_ether_addr(new_addr)) {
 		EFX_ERR(efx, "invalid ethernet MAC address requested: %pM\n",
 			new_addr);
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 	}
 
 	memcpy(net_dev->dev_addr, new_addr, net_dev->addr_len);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index a69c4a4..c4e385b 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1146,7 +1146,7 @@ static int tsi108_set_mac(struct net_device *dev, void *addr)
 	int i;
 
 	if (!is_valid_ether_addr(addr))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	for (i = 0; i < 6; i++)
 		/* +2 is for the offset of the HW addr type */
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 3d406f9..eb59c2d 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -410,7 +410,7 @@ static int dm9601_set_mac_address(struct net_device *net, void *p)
 	if (!is_valid_ether_addr(addr->sa_data)) {
 		dev_err(&net->dev, "not setting invalid mac address %pM\n",
 								addr->sa_data);
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 	}
 
 	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 8737431..1b4d77a 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -473,7 +473,7 @@ static int mcs7830_set_mac_address(struct net_device *netdev, void *p)
 		return -EBUSY;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index f1c4b2a..4b36d06 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1301,7 +1301,7 @@ static int vxge_set_mac_addr(struct net_device *dev, void *p)
 	hldev = vdev->devh;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	memset(&mac_info_new, 0, sizeof(struct macInfo));
 	memset(&mac_info_old, 0, sizeof(struct macInfo));
