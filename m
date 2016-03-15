From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net] ravb: fix result value overwrite
Date: Wed, 16 Mar 2016 00:52:16 +0900
Message-ID: <1458057136-23253-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The result value is overwritten by a return value of
ravb_ptp_interrupt().

Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking tree.

 drivers/net/ethernet/renesas/ravb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 86449c3..d369af8 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -765,8 +765,8 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 		result = IRQ_HANDLED;
 	}
 
-	if (iss & ISS_CGIS)
-		result = ravb_ptp_interrupt(ndev);
+	if ((iss & ISS_CGIS) && ravb_ptp_interrupt(ndev) == IRQ_HANDLED)
+		result = IRQ_HANDLED;
 
 	mmiowb();
 	spin_unlock(&priv->lock);
-- 
1.9.1
