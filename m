From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v1 1/2] ethtool-copy.h:sync with net
Date: Sun, 28 Aug 2016 23:56:49 -0700
Message-ID: <1472453810-47177-2-git-send-email-vidya@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dustin@cumulusnetworks.com
To: linville@tuxdriver.com, netdev@vger.kernel.org, bwh@kernel.org,
        davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35358 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756443AbcH2G47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 02:56:59 -0400
Received: by mail-pf0-f177.google.com with SMTP id x72so48970487pfd.2
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 23:56:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This covers kernel changes upto:

commit 5711a98221443aec54c4c81ee98c6ae46acccb65
Author: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Date:   Fri Aug 26 01:25:50 2016 -0700

    net: ethtool: add support for 1000BaseX and missing 10G link modes

    This patch enhances ethtool link mode bitmap to include
    missing interface modes for 1G/10G speeds

    Changes:
    1000baseX is the mode introduced to cover all 1G Fiber cases.
    All modes under 1000BaseX i.e. 1000BASE-SX, 1000BASE-LX, 1000BASE-LX10
    and 1000BASE-BX10 are not explicitly defined at this moment.
    10G CR,SR,LR and ER link modes are included for 10G speed..

    Issue:
    ethtool on  1G/10G SFP port reports Base-T
    as this port supports 1000baseX,10G CR, SR and LR modes.

    root@tor-02$ ethtool swp1
    Settings for swp1:
            Supported ports: [ FIBRE ]
            Supported link modes:   1000baseT/Full
                                    10000baseT/Full
            Supported pause frame use: Symmetric Receive-only
            Supports auto-negotiation: Yes
            Advertised link modes:  1000baseT/Full
            Advertised pause frame use: No
            Advertised auto-negotiation: No
            Speed: 10000Mb/s
            Duplex: Full
            Port: FIBRE
            PHYAD: 0
            Transceiver: external
            Auto-negotiation: off
            Current message level: 0x00000000 (0)

            Link detected: yes

   After fix:
    root@tor-02$ ethtool swp1
    Settings for swp1:
            Supported ports: [ FIBRE ]
            Supported link modes:   1000baseX/Full
                                    10000baseCR/Full
                                    10000baseSR/Full
                                    10000baseLR/Full
                                    10000baseER/Full
            Supported pause frame use: Symmetric Receive-only
            Supports auto-negotiation: Yes
            Advertised link modes:  1000baseT/Full
            Advertised pause frame use: No
            Advertised auto-negotiation: No
            Speed: 10000Mb/s
            Duplex: Full
            Port: FIBRE
            PHYAD: 0
            Transceiver: external
            Auto-negotiation: off
            Current message level: 0x00000000 (0)
            Link detected: yes

    Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 ethtool-copy.h | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 246f7b0..70748f5 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1360,7 +1360,14 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT	= 37,
 	ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT	= 38,
 	ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT	= 39,
-	ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT         = 40,
+	ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT		= 40,
+	ETHTOOL_LINK_MODE_1000baseX_Full_BIT	= 41,
+	ETHTOOL_LINK_MODE_10000baseCR_Full_BIT	= 42,
+	ETHTOOL_LINK_MODE_10000baseSR_Full_BIT	= 43,
+	ETHTOOL_LINK_MODE_10000baseLR_Full_BIT	= 44,
+	ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT	= 45,
+	ETHTOOL_LINK_MODE_10000baseER_Full_BIT	= 46,
+
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1369,7 +1376,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
+	  = ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
2.1.4
