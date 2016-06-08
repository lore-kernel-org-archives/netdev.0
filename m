From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] stmmac: fix parameter to dwmac4_set_umac_addr()
Date: Wed,  8 Jun 2016 19:21:17 +0100
Message-ID: <1465410077-25381-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	netdev@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-70-136-246.dsl.in-addr.zen.co.uk ([82.70.136.246]:53744 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1162016AbcFHSVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:21:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dwmac4_set_umac_addr() takes a struct mac_device_info as
the first parameter, but is being passed a ioaddr instead from
dwmac4_set_filter(). Fix the warning/bug by changing the first
parameter.

drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46: warning: incorrect type in argument 1 (different address spaces)
drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46:    expected struct mac_device_info *hw
drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46:    got void [noderef] <asn:2>*ioaddr

Note, only compile tested this as do not have any
hardware with it in.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 4f7283d..44da877 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -156,7 +156,7 @@ static void dwmac4_set_filter(struct mac_device_info *hw,
 		struct netdev_hw_addr *ha;
 
 		netdev_for_each_uc_addr(ha, dev) {
-			dwmac4_set_umac_addr(ioaddr, ha->addr, reg);
+			dwmac4_set_umac_addr(hw, ha->addr, reg);
 			reg++;
 		}
 	}
-- 
2.8.1
