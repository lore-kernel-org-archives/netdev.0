From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cnic : Cleanup CONFIG_IPV6 & VLAN check
Date: Thu,  4 Sep 2014 17:12:57 -0700
Message-ID: <1409875977-31584-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, jitendra.kalsaria@qlogic.com,
	mchan@broadcom.com, eddie.wai@broadcom.com,
	randy.dunlap@oracle.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59623
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754446AbaIEANH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 20:13:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cnic module needs to ensure that if ipv6 support is compiled as a module,
then the cnic module cannot be compiled as built-in as it depends on ipv6.
Made this check cleaner via Kconfig

Use simpler IS_ENABLED for CONFIG_VLAN_8021Q check

Signed-off-by: Anish Bhatt <anish@chelsio.com>

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 7dcfb19..d8d07a8 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -84,7 +84,7 @@ config BNX2
 
 config CNIC
 	tristate "QLogic CNIC support"
-	depends on PCI
+	depends on PCI && (IPV6 || IPV6=n)
 	select BNX2
 	select UIO
 	---help---
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 27861a6..a6a9f28 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -31,7 +31,7 @@
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <linux/random.h>
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 #define BCM_VLAN 1
 #endif
 #include <net/ip.h>
@@ -3685,7 +3685,7 @@ static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
 static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 			     struct dst_entry **dst)
 {
-#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
+#if IS_ENABLED(CONFIG_IPV6)
 	struct flowi6 fl6;
 
 	memset(&fl6, 0, sizeof(fl6));
-- 
2.1.0
