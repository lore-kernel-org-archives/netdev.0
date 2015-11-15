From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net] ravb: remove unhandle int cause
Date: Sun, 15 Nov 2015 21:34:42 +0900
Message-ID: <1447590882-20742-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masaru Nagai <masaru.nagai.vx@renesas.com>

This driver does not handle the AVB-DMAC Receive FIFO Warning interrupt
now, so the interrupt should not be enabled.

Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking tree.

 drivers/net/ethernet/renesas/ravb_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index aa7b208..3d5c4ac 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -408,8 +408,6 @@ static int ravb_dmac_init(struct net_device *ndev)
 	/* Interrupt enable: */
 	/* Frame receive */
 	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
-	/* Receive FIFO full warning */
-	ravb_write(ndev, RIC1_RFWE, RIC1);
 	/* Receive FIFO full error, descriptor empty */
 	ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
 	/* Frame transmitted, timestamp FIFO updated */
-- 
1.9.1

