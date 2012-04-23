From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH net] net/davinci_emac: fix failing PHY connect attempts
Date: Tue, 24 Apr 2012 00:06:43 +0200
Message-ID: <1335218803-8664-1-git-send-email-agust@denx.de>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:57485 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755201Ab2DWWHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 18:07:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY connect attempts fail if no PHY id is specified in the emac platform
data and another mdio bus has been registered before 'davinci_mdio' bus. In
this case when configuring the interface, there will be an attempt to
connect to already attached PHY on the previously registered mdio bus:

net eth1: PHY already attached
net eth1: could not connect to phy smsc911x-0:01
IP-Config: Failed to open eth1
IP-Config: Device `eth1' not found

Fix this by modifying match_first_device() to match first PHY device
on 'davinci_mdio' bus.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/ethernet/ti/davinci_emac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 174a334..08aff1a 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1511,7 +1511,7 @@ static int emac_devioctl(struct net_device *ndev, struct ifreq *ifrq, int cmd)
 
 static int match_first_device(struct device *dev, void *data)
 {
-	return 1;
+	return !strncmp(dev_name(dev), "davinci_mdio", 12);
 }
 
 /**
-- 
1.7.1
