From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] qed: add qed_int_sb_init() stub function
Date: Fri,  9 Jun 2017 12:37:35 +0200
Message-ID: <20170609103744.3239316-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_QED_SRIOV is disabled, we get a build error:

drivers/net/ethernet/qlogic/qed/qed_int.c: In function 'qed_int_sb_init':
drivers/net/ethernet/qlogic/qed/qed_int.c:1499:4: error: implicit declaration of function 'qed_vf_set_sb_info'; did you mean 'qed_mcp_get_resc_info'? [-Werror=implicit-function-declaration]

All the other declarations have a 'static inline' stub as an alternative
here, so this adds one more for qed_int_sb_init.

Fixes: 50a207147fce ("qed: Hold a single array for SBs")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/qlogic/qed/qed_vf.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index b65bbc54a097..34d9b882a780 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -1105,6 +1105,11 @@ static inline u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 	return 0;
 }
 
+static inline void qed_vf_set_sb_info(struct qed_hwfn *p_hwfn, u16 sb_id,
+				      struct qed_sb_info *p_sb)
+{
+}
+
 static inline int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
 					u8 vport_id,
 					u16 mtu,
-- 
2.9.0
