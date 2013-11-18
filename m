From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 2/9] net: stmmac: mdio: remove reset gpio free
Date: Mon, 18 Nov 2013 11:31:49 +0000
Message-ID: <1384774309-10136-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:56422 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751057Ab3KRLdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 06:33:38 -0500
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes gpio_free for reset line of the phy, driver stores
the gpio number in its private data-structure to use in future. As the
driver uses this pin in future this pin should not be freed.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index fe7bc99..aab12d2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -166,7 +166,6 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 			udelay(data->delays[1]);
 			gpio_set_value(reset_gpio, active_low ? 1 : 0);
 			udelay(data->delays[2]);
-			gpio_free(reset_gpio);
 		}
 	}
 #endif
-- 
1.7.6.5
