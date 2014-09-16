From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/8] net: phy: broadcom: add helper for PHY revision and patch level
Date: Tue, 16 Sep 2014 16:52:58 -0700
Message-ID: <1410911584-1559-3-git-send-email-f.fainelli@gmail.com>
References: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:39013 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbaIPXxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 19:53:54 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so825704pab.15
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 16:53:54 -0700 (PDT)
In-Reply-To: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom BCM7xxx internal PHYs do not contain any useful revision
information in the low 4-bits of their MII_PHYSID2 (MII register 3)
which could allow us to properly identify them.

As a result, we need the actual hardware block integrating these PHYs:
GENET or the SF2 switch to tell us what revision they are built with. To
assist with that, add two helper macros for fetching the the PHY
revision and patch level from the struct phy_device::dev_flags.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/brcmphy.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 5bd35cc0d471..e4ee9c6679e8 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -41,6 +41,8 @@
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
 /* Broadcom BCM7xxx specific workarounds */
 #define PHY_BRCM_100MBPS_WAR		0x00010000
+#define PHY_BRCM_7XXX_REV(x)		(((x) >> 8) & 0xff)
+#define PHY_BRCM_7XXX_PATCH(x)		((x) & 0xff)
 #define PHY_BCM_FLAGS_VALID		0x80000000
 
 /* Broadcom BCM54XX register definitions, common to most Broadcom PHYs */
-- 
1.9.1
