From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 1/2] mdio: Export mdio.h to userland
Date: Thu, 1 Mar 2012 00:23:27 +0000
Message-ID: <1330561407.5881.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:14637 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757693Ab2CAAXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 19:23:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ID packing definitions are needed by userland and the register
definitions may also be useful there.

Do not export mdio_phy_id_{is_c45,prtad,devad}() as the use of bool is
problematic and it's not that useful to export only a subset of these.

Do not export MDIO_SUPPORTS_{C22,C45} directly; these flags are only
exposed to userland through struct ethtool_cmd so they should be
defined alongside that with appropriate names.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/Kbuild |    1 +
 include/linux/mdio.h |    9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index c94e717..4b0b7ed 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -238,6 +238,7 @@ header-y += magic.h
 header-y += major.h
 header-y += map_to_7segment.h
 header-y += matroxfb.h
+header-y += mdio.h
 header-y += media.h
 header-y += mempolicy.h
 header-y += meye.h
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index b1494ac..dec1e87 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -273,6 +273,8 @@ static inline __u16 mdio_phy_id_c45(int prtad, int devad)
 	return MDIO_PHY_ID_C45 | (prtad << 5) | devad;
 }
 
+#ifdef __KERNEL__ 
+
 static inline bool mdio_phy_id_is_c45(int phy_id)
 {
 	return (phy_id & MDIO_PHY_ID_C45) && !(phy_id & ~MDIO_PHY_ID_C45_MASK);
@@ -288,11 +290,6 @@ static inline __u16 mdio_phy_id_devad(int phy_id)
 	return phy_id & MDIO_PHY_ID_DEVAD;
 }
 
-#define MDIO_SUPPORTS_C22		1
-#define MDIO_SUPPORTS_C45		2
-
-#ifdef __KERNEL__ 
-
 /**
  * struct mdio_if_info - Ethernet controller MDIO interface
  * @prtad: PRTAD of the PHY (%MDIO_PRTAD_NONE if not present/unknown)
@@ -321,6 +318,8 @@ struct mdio_if_info {
 
 #define MDIO_PRTAD_NONE			(-1)
 #define MDIO_DEVAD_NONE			(-1)
+#define MDIO_SUPPORTS_C22		1
+#define MDIO_SUPPORTS_C45		2
 #define MDIO_EMULATE_C22		4
 
 struct ethtool_cmd;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
