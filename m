From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net 4/5] stmmac: Enable unicast pause frame detect in GMAC Register 6
Date: Wed, 15 Apr 2015 11:17:41 -0500
Message-ID: <1429114662-1528-5-git-send-email-vbridger@opensource.altera.com>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@opensource.altera.com>, <vbridger@altera.com>
To: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0080.outbound.protection.outlook.com ([157.56.111.80]:54269
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751848AbbDOUzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 16:55:11 -0400
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unicast pause frame detect was not being enabled for the Synopsys stmmac. This
patch sets Unicast pause frame detect in MAC register 6 so that pause frame
detection by the stmmac conforms to IEEE 802.3, Annex 31B.3.3 Receive
Operation - Specifically, a MAC shall respond to pause frames containing
either the reserved multicast address or the unique physical address
associated with this station.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 0adcf73..371a669 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -201,7 +201,10 @@ static void dwmac1000_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 				unsigned int fc, unsigned int pause_time)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	unsigned int flow = 0;
+	/* Set flow such that DZPQ in Mac Register 6 is 0,
+	 * and unicast pause detect is enabled.
+	 */
+	unsigned int flow = GMAC_FLOW_CTRL_UP;
 
 	pr_debug("GMAC Flow-Control:\n");
 	if (fc & FLOW_RX) {
-- 
1.9.1
