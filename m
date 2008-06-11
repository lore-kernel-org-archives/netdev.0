From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] smc91x: fix build error from the SMC_GET_MAC_ADDR API change
Date: Wed, 11 Jun 2008 12:08:39 +0800
Message-ID: <1213157319-27857-1-git-send-email-cooloney@kernel.org>
Cc: linux-kernel@vger.kernel.org, bunk@kernel.org,
	vapier.adi@gmail.com, netdev@vger.kernel.org,
	Bryan Wu <cooloney@kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:55066 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbYFKEIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 00:08:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/smc91x.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 69e97a1..8606818 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
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
-- 
1.5.5
