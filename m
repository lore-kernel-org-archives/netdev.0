From: akpm@linux-foundation.org
Subject: [patch for 2.6.25? 1/3] smc91x: fix build breakage from the SMC_GET_MAC_ADDR API upgrade
Date: Thu, 27 Mar 2008 00:45:10 -0700
Message-ID: <200803270745.m2R7jAX2024160@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	cooloney@kernel.org, dsaxena@plexity.net, lethal@linux-sh.org,
	nico@cam.org, rmk+kernel@arm.linux.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51165 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755182AbYC0Hpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 03:45:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan Wu <cooloney@kernel.org>

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Deepak Saxena <dsaxena@plexity.net>
Cc: Nicolas Pitre <nico@cam.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc91x.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/smc91x.h~smc91x-fix-build-breakage-from-the-smc_get_mac_addr-api-upgrade drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~smc91x-fix-build-breakage-from-the-smc_get_mac_addr-api-upgrade
+++ a/drivers/net/smc91x.h
@@ -93,14 +93,14 @@
 #define SMC_insw(a, r, p, l) 	insw ((unsigned long *)((a) + (r)), p, l)
 # endif
 /* check if the mac in reg is valid */
-#define SMC_GET_MAC_ADDR(addr)					\
+#define SMC_GET_MAC_ADDR(lp, addr)				\
 	do {							\
 		unsigned int __v;				\
-		__v = SMC_inw(ioaddr, ADDR0_REG);		\
+		__v = SMC_inw(ioaddr, ADDR0_REG(lp));		\
 		addr[0] = __v; addr[1] = __v >> 8;		\
-		__v = SMC_inw(ioaddr, ADDR1_REG);		\
+		__v = SMC_inw(ioaddr, ADDR1_REG(lp));		\
 		addr[2] = __v; addr[3] = __v >> 8;		\
-		__v = SMC_inw(ioaddr, ADDR2_REG);		\
+		__v = SMC_inw(ioaddr, ADDR2_REG(lp));		\
 		addr[4] = __v; addr[5] = __v >> 8;		\
 		if (*(u32 *)(&addr[0]) == 0xFFFFFFFF) {		\
 			random_ether_addr(addr);		\
_
