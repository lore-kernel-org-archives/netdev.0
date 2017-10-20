From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 3/3] net: stmmac: Prevent infinite loop in get_rx_timestamp_status()
Date: Fri, 20 Oct 2017 14:37:36 +0100
Message-ID: <a5577e256ec3360f81975984bb27224d2c2dc90f.1508506265.git.joabreu@synopsys.com>
References: <cover.1508506265.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508506265.git.joabreu@synopsys.com>
In-Reply-To: <cover.1508506265.git.joabreu@synopsys.com>
References: <cover.1508506265.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prevent infinite loop by correctly setting the loop condition to
break when i == 10.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index e0ef02f..4b286e2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -275,7 +275,7 @@ static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 					goto exit;
 				i++;
 
-			} while ((ret == 1) || (i < 10));
+			} while ((ret == 1) && (i < 10));
 
 			if (i == 10)
 				ret = -EBUSY;
-- 
1.9.1
