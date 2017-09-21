From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 33/64] drivers: net: amd8111e: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:54 +0530
Message-ID: <1506013525-29291-34-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/amd/amd8111e.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 7b5df56..7f22af6 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1883,9 +1883,8 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	/* Initialize software ipg timer */
 	if(lp->options & OPTION_DYN_IPG_ENABLE){
-		init_timer(&lp->ipg_data.ipg_timer);
-		lp->ipg_data.ipg_timer.data = (unsigned long) dev;
-		lp->ipg_data.ipg_timer.function = (void *)&amd8111e_config_ipg;
+		setup_timer(&lp->ipg_data.ipg_timer,
+			    (void *)&amd8111e_config_ipg, (unsigned long)dev);
 		lp->ipg_data.ipg_timer.expires = jiffies +
 						 IPG_CONVERGE_JIFFIES;
 		lp->ipg_data.ipg = DEFAULT_IPG;
-- 
2.7.4
