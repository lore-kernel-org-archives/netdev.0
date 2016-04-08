From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] drivers/net/ethernet/jme.c: Deinline jme_reset_mac_processor, save 2816 bytes
Date: Fri,  8 Apr 2016 20:39:47 +0200
Message-ID: <1460140787-12610-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbcDHSjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 14:39:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function compiles to 895 bytes of machine code.

Clearly, this isn't a time-critical function.
For one, it has a number of udelay(1) calls.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: David S. Miller <davem@davemloft.net>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/jme.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 3ddf657..711cb19 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -222,7 +222,7 @@ jme_clear_ghc_reset(struct jme_adapter *jme)
 	jwrite32f(jme, JME_GHC, jme->reg_ghc);
 }
 
-static inline void
+static void
 jme_reset_mac_processor(struct jme_adapter *jme)
 {
 	static const u32 mask[WAKEUP_FRAME_MASK_DWNR] = {0, 0, 0, 0};
-- 
2.1.0
