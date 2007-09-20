From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: ethtool speed report bug
Date: Wed, 19 Sep 2007 22:06:01 -0700
Message-ID: <20070920050700.384830557@linux-foundation.org>
References: <20070920050559.763089637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzk <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51560 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751302AbXITFH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:07:56 -0400
Content-Disposition: inline; filename=sky2-ethtool-100mbit.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 100mbit versions, the driver always reports gigabit speed
available. The correct modes are already computed, then overwritten.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-19 21:35:53.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-19 21:35:57.000000000 -0700
@@ -2880,13 +2880,6 @@ static int sky2_get_settings(struct net_
 	ecmd->supported = sky2_supported_modes(hw);
 	ecmd->phy_address = PHY_ADDR_MARV;
 	if (sky2_is_copper(hw)) {
-		ecmd->supported = SUPPORTED_10baseT_Half
-		    | SUPPORTED_10baseT_Full
-		    | SUPPORTED_100baseT_Half
-		    | SUPPORTED_100baseT_Full
-		    | SUPPORTED_1000baseT_Half
-		    | SUPPORTED_1000baseT_Full
-		    | SUPPORTED_Autoneg | SUPPORTED_TP;
 		ecmd->port = PORT_TP;
 		ecmd->speed = sky2->speed;
 	} else {

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

