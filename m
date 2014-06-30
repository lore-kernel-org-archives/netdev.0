From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 3/3] net: stmmac: Remove unneeded I/O read caught by cppcheck
Date: Sun, 29 Jun 2014 20:34:53 -0500
Message-ID: <1404092093-18630-4-git-send-email-vbridgers2013@gmail.com>
References: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: netdev@vger.kernel.org, davem@davemloft.net, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:35829 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbaF3Biw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:38:52 -0400
Received: by mail-oa0-f45.google.com with SMTP id o6so8162414oag.32
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 18:38:51 -0700 (PDT)
In-Reply-To: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cppcheck found a case where a local variable was being assigned a value,
but not used. There seems to be no reason to read this register before
assigning a new value, so addressing thie issue.

cppcheck --force --enable=all --inline-suppr . shows ...

Variable 'value' is reassigned a value before the old one has been used.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: No change, new trivial patch in this series
---
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index b3e148e..9d37483 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -320,11 +320,8 @@ static void dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
 
 static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
 {
-	u32 value;
-
-	value = readl(ioaddr + GMAC_AN_CTRL);
 	/* auto negotiation enable and External Loopback enable */
-	value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
+	u32 value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
 
 	if (restart)
 		value |= GMAC_AN_CTRL_RAN;
-- 
1.7.9.5
