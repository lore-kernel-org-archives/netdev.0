From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: ethoc: remove ethoc_config
Date: Mon, 21 Apr 2014 09:09:19 -0700
Message-ID: <1398096563-8786-2-git-send-email-f.fainelli@gmail.com>
References: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bh74.an@samsung.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, peppe.cavallaro@st.com,
	jcmvbkbc@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:52868 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaDUQJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:09:36 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so4208687qcx.27
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 09:09:36 -0700 (PDT)
In-Reply-To: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethoc_config() returns -ENOSYS and does not implement anything useful,
let's remove it such that net/core/dev_ioctl.c::dev_ifsioc can return
something meaningful like -EOPNOTSUPP.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8b70ca7e342b..f3658bdb64cc 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -769,11 +769,6 @@ static int ethoc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return phy_mii_ioctl(phy, ifr, cmd);
 }
 
-static int ethoc_config(struct net_device *dev, struct ifmap *map)
-{
-	return -ENOSYS;
-}
-
 static void ethoc_do_set_mac_address(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
@@ -995,7 +990,6 @@ static const struct net_device_ops ethoc_netdev_ops = {
 	.ndo_open = ethoc_open,
 	.ndo_stop = ethoc_stop,
 	.ndo_do_ioctl = ethoc_ioctl,
-	.ndo_set_config = ethoc_config,
 	.ndo_set_mac_address = ethoc_set_mac_address,
 	.ndo_set_rx_mode = ethoc_set_multicast_list,
 	.ndo_change_mtu = ethoc_change_mtu,
-- 
1.9.1
