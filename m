From: Pavel Belous <pavel.s.belous@gmail.com>
Subject: [PATCH] ethtool: Add support for 2500baseT/5000baseT link modes
Date: Mon, 30 Jan 2017 20:03:30 +0300
Message-ID: <1485795810-6558-1-git-send-email-pavel.s.belous@gmail.com>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35301 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdA3RE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 12:04:29 -0500
Received: by mail-lf0-f67.google.com with SMTP id v186so31896412lfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 09:04:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduce ethtool support for 2500BaseT and 5000BaseT link modes
from new IEEE 802.3bz standard.

ethtool-copy.h file sync with net.

Signed-off-by: Pavel Belous <pavel.s.belous@gmail.com>
---
 ethtool-copy.h | 4 +++-
 ethtool.8.in   | 4 +++-
 ethtool.c      | 6 ++++++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3d299e3..06fc04c 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1382,6 +1382,8 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_10000baseLR_Full_BIT	= 44,
 	ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT	= 45,
 	ETHTOOL_LINK_MODE_10000baseER_Full_BIT	= 46,
+	ETHTOOL_LINK_MODE_2500baseT_Full_BIT = 47,
+	ETHTOOL_LINK_MODE_5000baseT_Full_BIT = 48,
 
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
@@ -1391,7 +1393,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
+	  = ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
diff --git a/ethtool.8.in b/ethtool.8.in
index 5c36c06..1e564ae 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -588,7 +588,9 @@ lB	l	lB.
 0x020	1000baseT Full
 0x20000	1000baseKX Full
 0x20000000000	1000baseX Full
-0x8000	2500baseX Full	(not supported by IEEE standards)
+0x800000000000  2500baseT Full
+0x8000	2500baseX Full	(not supported by IEEE standards)'
+0x1000000000000  5000baseT Full
 0x1000	10000baseT Full
 0x40000	10000baseKX4 Full
 0x80000	10000baseKR Full
diff --git a/ethtool.c b/ethtool.c
index 7af039e..031afe8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -529,6 +529,8 @@ static void init_global_link_mode_masks(void)
 		ETHTOOL_LINK_MODE_10000baseLR_Full_BIT,
 		ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT,
 		ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
+		ETHTOOL_LINK_MODE_2500baseT_Full_BIT,
+		ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
 	};
 	static const enum ethtool_link_mode_bit_indices
 		additional_advertised_flags_bits[] = {
@@ -681,6 +683,10 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 		  "10000baseLRM/Full" },
 		{ 0, ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
 		  "10000baseER/Full" },
+                { 0, ETHTOOL_LINK_MODE_2500baseT_Full_BIT,
+                  "2500baseT/Full" },
+                { 0, ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
+                  "5000baseT/Full" },
 	};
 	int indent;
 	int did1, new_line_pend, i;
-- 
2.7.4
