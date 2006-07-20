From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] via-velocity: fix reported speed and link detected status
Date: Wed, 19 Jul 2006 22:28:54 -0500
Message-ID: <20060720032854.GA4520@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf23aec.mail.bellsouth.net ([205.152.59.71]:17767 "EHLO
	imf23aec.mail.bellsouth.net") by vger.kernel.org with ESMTP
	id S932556AbWGTD25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 23:28:57 -0400
Received: from ibm66aec.bellsouth.net ([70.152.106.223])
          by imf23aec.mail.bellsouth.net with ESMTP
          id <20060720032855.NTFQ24081.imf23aec.mail.bellsouth.net@ibm66aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Wed, 19 Jul 2006 23:28:55 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The via-velocity driver reports incorrect speed and link detected status as viewed by ethtool (and probably other tools). This patch fixes those incorrect reports and prettifies a long line.

Signed-off-by:  Jay Cliburn <jacliburn@bellsouth.net>

--- linux-2.6.17.x86_64/drivers/net/via-velocity.c.orig 2006-07-19 18:34:15.000000000 -0500
+++ linux-2.6.17.x86_64/drivers/net/via-velocity.c      2006-07-19 18:55:05.000000000 -0500
@@ -2742,7 +2742,7 @@ static u32 check_connection_type(struct 
 
        if (PHYSR0 & PHYSR0_SPDG)
                status |= VELOCITY_SPEED_1000;
-       if (PHYSR0 & PHYSR0_SPD10)
+       else if (PHYSR0 & PHYSR0_SPD10)
                status |= VELOCITY_SPEED_10;
        else
                status |= VELOCITY_SPEED_100;
@@ -2851,8 +2851,17 @@ static int velocity_get_settings(struct 
        u32 status;
        status = check_connection_type(vptr->mac_regs);
 
-       cmd->supported = SUPPORTED_TP | SUPPORTED_Autoneg | SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full;
-       if (status & VELOCITY_SPEED_100)
+       cmd->supported = SUPPORTED_TP |
+                        SUPPORTED_Autoneg |
+                        SUPPORTED_10baseT_Half |
+                        SUPPORTED_10baseT_Full |
+                        SUPPORTED_100baseT_Half |
+                        SUPPORTED_100baseT_Full |
+                        SUPPORTED_1000baseT_Half |
+                        SUPPORTED_1000baseT_Full;
+       if (status & VELOCITY_SPEED_1000)
+               cmd->speed = SPEED_1000;
+       else if (status & VELOCITY_SPEED_100)
                cmd->speed = SPEED_100;
        else
                cmd->speed = SPEED_10;
@@ -2896,7 +2905,7 @@ static u32 velocity_get_link(struct net_
 {
        struct velocity_info *vptr = netdev_priv(dev);
        struct mac_regs __iomem * regs = vptr->mac_regs;
-       return BYTE_REG_BITS_IS_ON(PHYSR0_LINKGD, &regs->PHYSR0)  ? 0 : 1;
+       return BYTE_REG_BITS_IS_ON(PHYSR0_LINKGD, &regs->PHYSR0) ? 1 : 0;
 }
 
 static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)

