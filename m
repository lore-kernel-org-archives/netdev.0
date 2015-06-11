From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] b44: Utilize BRCM_PSEUDO_PHY_ADDR
Date: Wed, 10 Jun 2015 18:07:59 -0700
Message-ID: <1433984881-28781-4-git-send-email-f.fainelli@gmail.com>
References: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, hauke@hauke-m.de,
	zajec5@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35213 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbFKBJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 21:09:15 -0400
Received: by qgg3 with SMTP id 3so21567782qgg.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 18:09:14 -0700 (PDT)
In-Reply-To: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What B44 has been locally using as B44_PHY_ADDR_NO_LOCAL_PHY is in fact
the Broadcom Ethernet switches pseudo-PHY address (30). Update the
header to use the newly introduced constant and update comments so they
are within 80 columns and consistent.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/b44.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index 3e9c3fc7591b..65d88d7c5581 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -1,6 +1,8 @@
 #ifndef _B44_H
 #define _B44_H
 
+#include <linux/brcmphy.h>
+
 /* Register layout. (These correspond to struct _bcmenettregs in bcm4400.) */
 #define	B44_DEVCTRL	0x0000UL /* Device Control */
 #define  DEVCTRL_MPM		0x00000040 /* Magic Packet PME Enable (B0 only) */
@@ -281,8 +283,10 @@ struct ring_info {
 };
 
 #define B44_MCAST_TABLE_SIZE		32
-#define B44_PHY_ADDR_NO_LOCAL_PHY	30 /* no local phy regs */
-#define B44_PHY_ADDR_NO_PHY		31 /* no phy present at all */
+/* no local phy regs, e.g: Broadcom switches pseudo-PHY */
+#define B44_PHY_ADDR_NO_LOCAL_PHY	BRCM_PSEUDO_PHY_ADDR
+/* no phy present at all */
+#define B44_PHY_ADDR_NO_PHY		31
 #define B44_MDC_RATIO			5000000
 
 #define	B44_STAT_REG_DECLARE		\
-- 
2.1.0
