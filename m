From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: ethtool speed report bug
Date: Wed, 19 Sep 2007 15:36:43 -0700
Message-ID: <20070919223746.550931886@linux-foundation.org>
References: <20070919223641.860189786@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzk <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58668 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755509AbXISXQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:16:50 -0400
Content-Disposition: inline; filename=sky2-ethtool-100mbit.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 100mbit versions, the driver always reports gigabit speed
available. The correct modes are already computed, then overwritten.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-19 09:18:50.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-19 09:19:35.000000000 -0700
@@ -2841,13 +2841,6 @@ static int sky2_get_settings(struct net_
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

