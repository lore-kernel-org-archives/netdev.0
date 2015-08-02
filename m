From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] rocker: enable support for scattered packets
Date: Sun,  2 Aug 2015 20:56:37 +0200
Message-ID: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33964 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbbHBS4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 14:56:41 -0400
Received: by wibud3 with SMTP id ud3so111279948wib.1
        for <netdev@vger.kernel.org>; Sun, 02 Aug 2015 11:56:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

rocker supports the transmission of scattered packets, so let the kernel
know about it by setting the NETIF_F_SG bit in the device's features.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 7b4c347..730bdc0 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4970,7 +4970,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 		       NAPI_POLL_WEIGHT);
 	rocker_carrier_init(rocker_port);
 
-	dev->features |= NETIF_F_NETNS_LOCAL;
+	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_SG;
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.9.3
