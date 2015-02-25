From: Ameen Ali <ameenali023@gmail.com>
Subject: [PATCH 6/6] qlcnic_dcb.c : possible division by zero.
Date: Thu, 26 Feb 2015 00:05:14 +0200
Message-ID: <1424901914-6582-1-git-send-email-ameenali023@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ameen Ali <ameenali023@gmail.com>
To: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whenever there is a division it is usually worthwhile to
add some belt'n'braces code to ensure that cnt != 0, otherwise
a machine signal can occur.

Signed-off-by : Ameen Ali <Ameenali023@gmail.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index a72bcdd..c1d5e48 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -822,7 +822,7 @@ qlcnic_dcb_get_pg_tc_cfg_tx(struct net_device *netdev, int tc, u8 *prio,
 		if (temp->valid && (pg == temp->pgid))
 			cnt++;
 	}
-
+	if (cnt != 0)
 	    tc_cfg->bwg_percent = (100 / cnt);
 	*bw_per = tc_cfg->bwg_percent;
 }
-- 
2.1.0
