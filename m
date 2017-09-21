From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 54/64] drivers: net: hdlc_ppp: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:15 +0530
Message-ID: <1506013525-29291-55-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/wan/hdlc_ppp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 0d2e00e..c7721c7 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -610,9 +610,7 @@ static void ppp_start(struct net_device *dev)
 	for (i = 0; i < IDX_COUNT; i++) {
 		struct proto *proto = &ppp->protos[i];
 		proto->dev = dev;
-		init_timer(&proto->timer);
-		proto->timer.function = ppp_timer;
-		proto->timer.data = (unsigned long)proto;
+		setup_timer(&proto->timer, ppp_timer, (unsigned long)proto);
 		proto->state = CLOSED;
 	}
 	ppp->protos[IDX_LCP].pid = PID_LCP;
-- 
2.7.4
