From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: systemport: Fix ordering in intrl2_*_mask_clear macro
Date: Wed, 24 Aug 2016 14:21:41 -0700
Message-ID: <1472073701-24289-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36330 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753148AbcHXVVp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 17:21:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so1890406pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 14:21:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we keep shadow copies of which interrupt sources are enabled
through the intrl2_*_mask_{set,clear} macros, make sure that the
ordering in which we do these two operations: update the copy, then
unmask the register is correct.

This is not currently a problem because we actually do not use them, but
we will in a subsequent patch optimizing register accesses, so better be
safe here.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David,

This is intentionally targetting the "net-next" tree since it is
not yet a problem, yet this is still technically a bugfix. No need
to backport this to -stable or anything.

Thanks!

 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index b2d30863caeb..2059911014db 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -58,8 +58,8 @@ BCM_SYSPORT_IO_MACRO(topctrl, SYS_PORT_TOPCTRL_OFFSET);
 static inline void intrl2_##which##_mask_clear(struct bcm_sysport_priv *priv, \
 						u32 mask)		\
 {									\
-	intrl2_##which##_writel(priv, mask, INTRL2_CPU_MASK_CLEAR);	\
 	priv->irq##which##_mask &= ~(mask);				\
+	intrl2_##which##_writel(priv, mask, INTRL2_CPU_MASK_CLEAR);	\
 }									\
 static inline void intrl2_##which##_mask_set(struct bcm_sysport_priv *priv, \
 						u32 mask)		\
-- 
2.7.4
