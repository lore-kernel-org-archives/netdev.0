From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH RESEND] net: ethernet: renesas: ravb_main: test clock rate to avoid division by 0
Date: Fri,  8 Apr 2016 13:28:42 +0200
Message-ID: <1460114922-4148-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	linux-renesas-soc@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa+renesas@sang-engineering.com>

The clk API may return 0 on clk_get_rate, so we should check the result before
using it as a divisor.

Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---

The original patch was marked as "NOT APPLICABLE" in patchwork. I reviewed
again and can't see why. So, in case this remains true, please explain.

 drivers/net/ethernet/renesas/ravb_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 4e1a7dba7c4abb..791930b63991dc 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1691,6 +1691,9 @@ static int ravb_set_gti(struct net_device *ndev)
 	rate = clk_get_rate(clk);
 	clk_put(clk);
 
+	if (!rate)
+		return -EINVAL;
+
 	inc = 1000000000ULL << 20;
 	do_div(inc, rate);
 
-- 
2.7.0
