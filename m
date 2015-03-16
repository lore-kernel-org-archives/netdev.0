From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] dsa: change "select" to "depends on" for NET_SWITCHDEV and for NET_DSA
Date: Mon, 16 Mar 2015 12:33:32 +0100
Message-ID: <1426505612-2144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, f.fainelli@gmail.com, sfeldma@gmail.com,
	rdunlap@infradead.org, alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37983 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbCPLdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 07:33:38 -0400
Received: by wifj2 with SMTP id j2so40665670wif.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 04:33:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This would fix randconfig compile error:
net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
(.text+0xf7811): undefined reference to `fib_flush_external'

Also it fixes following warnings:
warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)

warning: (NET_DSA_MV88E6060 && NET_DSA_MV88E6131 && NET_DSA_MV88E6123_61_65 && NET_DSA_MV88E6171 && NET_DSA_MV88E6352 && NET_DSA_BCM_SF2) selects NET_DSA which has unmet direct dependencies (NET && HAVE_NET_DSA && NET_SWITCHDEV)

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/dsa/Kconfig | 13 ++++++-------
 net/dsa/Kconfig         |  3 +--
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 48e62a3..18550c7 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -7,7 +7,7 @@ config NET_DSA_MV88E6XXX
 
 config NET_DSA_MV88E6060
 	tristate "Marvell 88E6060 ethernet switch chip support"
-	select NET_DSA
+	depends on NET_DSA
 	select NET_DSA_TAG_TRAILER
 	---help---
 	  This enables support for the Marvell 88E6060 ethernet switch
@@ -19,7 +19,7 @@ config NET_DSA_MV88E6XXX_NEED_PPU
 
 config NET_DSA_MV88E6131
 	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
-	select NET_DSA
+	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_MV88E6XXX_NEED_PPU
 	select NET_DSA_TAG_DSA
@@ -29,7 +29,7 @@ config NET_DSA_MV88E6131
 
 config NET_DSA_MV88E6123_61_65
 	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
-	select NET_DSA
+	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
@@ -38,7 +38,7 @@ config NET_DSA_MV88E6123_61_65
 
 config NET_DSA_MV88E6171
 	tristate "Marvell 88E6171/6172 ethernet switch chip support"
-	select NET_DSA
+	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
@@ -47,7 +47,7 @@ config NET_DSA_MV88E6171
 
 config NET_DSA_MV88E6352
 	tristate "Marvell 88E6176/88E6352 ethernet switch chip support"
-	select NET_DSA
+	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
@@ -56,8 +56,7 @@ config NET_DSA_MV88E6352
 
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
-	depends on HAS_IOMEM
-	select NET_DSA
+	depends on HAS_IOMEM && NET_DSA
 	select NET_DSA_TAG_BRCM
 	select FIXED_PHY
 	select BCM7XXX_PHY
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index b45206e..9379a9c 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -6,9 +6,8 @@ config HAVE_NET_DSA
 
 config NET_DSA
 	tristate
-	depends on HAVE_NET_DSA
+	depends on HAVE_NET_DSA && NET_SWITCHDEV
 	select PHYLIB
-	select NET_SWITCHDEV
 
 if NET_DSA
 
-- 
1.9.3
