From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 61/64] drivers: net: enic: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:22 +0530
Message-ID: <1506013525-29291-62-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/ethernet/cisco/enic/enic_clsf.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.h b/drivers/net/ethernet/cisco/enic/enic_clsf.h
index 6aa9f89..4bfbf25 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.h
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.h
@@ -19,9 +19,8 @@ void enic_flow_may_expire(unsigned long data);
 
 static inline void enic_rfs_timer_start(struct enic *enic)
 {
-	init_timer(&enic->rfs_h.rfs_may_expire);
-	enic->rfs_h.rfs_may_expire.function = enic_flow_may_expire;
-	enic->rfs_h.rfs_may_expire.data = (unsigned long)enic;
+	setup_timer(&enic->rfs_h.rfs_may_expire, enic_flow_may_expire,
+		    (unsigned long)enic);
 	mod_timer(&enic->rfs_h.rfs_may_expire, jiffies + HZ/4);
 }
 
-- 
2.7.4
