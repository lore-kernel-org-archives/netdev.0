From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] sky2: no jumbo on Yukon FE
Date: Wed, 11 Apr 2007 14:48:02 -0700
Message-ID: <20070411214900.175464411@linux-foundation.org>
References: <20070411214757.194710334@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34869 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030473AbXDKWaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 18:30:46 -0400
Content-Disposition: inline; filename=sky2-fe-nojumbo.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Yukon FE (100mbit only) chips do not support large packets.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-11 14:40:42.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-11 14:41:09.000000000 -0700
@@ -1899,6 +1899,9 @@ static int sky2_change_mtu(struct net_de
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
+	if (new_mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_FE)
+		return -EINVAL;
+
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		return 0;

--
Stephen Hemminger <shemminger@linux-foundation.org>

