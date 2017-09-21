From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 56/64] drivers: net: cpsw_ale: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:17 +0530
Message-ID: <1506013525-29291-57-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/ti/cpsw_ale.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index ddd43e0..cd1185e 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -859,9 +859,7 @@ void cpsw_ale_start(struct cpsw_ale *ale)
 	cpsw_ale_control_set(ale, 0, ALE_ENABLE, 1);
 	cpsw_ale_control_set(ale, 0, ALE_CLEAR, 1);
 
-	init_timer(&ale->timer);
-	ale->timer.data	    = (unsigned long)ale;
-	ale->timer.function = cpsw_ale_timer;
+	setup_timer(&ale->timer, cpsw_ale_timer, (unsigned long)ale);
 	if (ale->ageout) {
 		ale->timer.expires = jiffies + ale->ageout;
 		add_timer(&ale->timer);
-- 
2.7.4
