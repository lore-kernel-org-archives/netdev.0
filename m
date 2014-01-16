From: <srinivas.kandagatla@st.com>
Subject: [PATCH v2 2/9] net: stmmac: mdio: remove reset gpio free
Date: Thu, 16 Jan 2014 10:51:58 +0000
Message-ID: <1389869518-28095-1-git-send-email-srinivas.kandagatla@st.com>
References: <1389869450-28003-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389869450-28003-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes gpio_free for reset line of the phy, driver stores
the gpio number in its private data-structure to use in future. As the
driver uses this pin in future this pin should not be freed.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
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
