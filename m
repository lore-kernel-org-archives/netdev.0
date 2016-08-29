From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v1 2/2] ethtool: add support for 1000BaseX and missing 10G link mode
Date: Sun, 28 Aug 2016 23:56:50 -0700
Message-ID: <1472453810-47177-3-git-send-email-vidya@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dustin@cumulusnetworks.com
To: linville@tuxdriver.com, netdev@vger.kernel.org, bwh@kernel.org,
        davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36382 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756457AbcH2G47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 02:56:59 -0400
Received: by mail-pf0-f169.google.com with SMTP id h186so48868185pfg.3
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 23:56:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch enhances ethtool link mode bitmap to include
missing interface modes for 1G/10G speeds

Changes:
a) 1000baseX is the mode introduced to cover all 1G Fiber cases.
All modes under 1000BaseX i.e. 1000BASE-SX, 1000BASE-LX, 1000BASE-LX10
and 1000BASE-BX10 are not explicitly defined at this moment.
10G CR,SR,LR and ER link modes are included for 10G speed..
b) Update description regarding QSFP+/QSFP28 support

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
        Advertised link modes:  1000baseX/Full
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
---
 ethtool.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index ab58c7f..6287b55 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -23,6 +23,7 @@
  * vmxnet3 support by Shrikrishna Khare <skhare@vmware.com>
  * Various features by Ben Hutchings <ben@decadent.org.uk>;
  *	Copyright 2008-2010, 2013-2016 Ben Hutchings
+ * QSFP+/QSFP28 DOM support by Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
  *
  * TODO:
  *   * show settings for all devices
@@ -522,6 +523,12 @@ static void init_global_link_mode_masks(void)
 		ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
 		ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
 		ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
+		ETHTOOL_LINK_MODE_1000baseX_Full_BIT,
+		ETHTOOL_LINK_MODE_10000baseCR_Full_BIT,
+		ETHTOOL_LINK_MODE_10000baseSR_Full_BIT,
+		ETHTOOL_LINK_MODE_10000baseLR_Full_BIT,
+		ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT,
+		ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
 	};
 	static const enum ethtool_link_mode_bit_indices
 		additional_advertised_flags_bits[] = {
@@ -662,6 +669,18 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 		  "100000baseLR4_ER4/Full" },
 		{ 0, ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
 		  "50000baseSR2/Full" },
+		{ 0, ETHTOOL_LINK_MODE_1000baseX_Full_BIT,
+		  "1000baseX/Full" },
+		{ 0, ETHTOOL_LINK_MODE_10000baseCR_Full_BIT,
+		  "10000baseCR/Full" },
+		{ 0, ETHTOOL_LINK_MODE_10000baseSR_Full_BIT,
+		  "10000baseSR/Full" },
+		{ 0, ETHTOOL_LINK_MODE_10000baseLR_Full_BIT,
+		  "10000baseLR/Full" },
+		{ 0, ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT,
+		  "10000baseLRM/Full" },
+		{ 0, ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
+		  "10000baseER/Full" },
 	};
 	int indent;
 	int did1, new_line_pend, i;
-- 
2.1.4
