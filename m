From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -next] enic: Make dummy rfs functions inline to fix !CONFIG_RFS_ACCEL build
Date: Wed, 25 Jun 2014 10:31:09 +0200
Message-ID: <1403685069-20198-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_RFS_ACCEL=n:

drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_open':
drivers/net/ethernet/cisco/enic/enic_main.c:1603:2: error: implicit declaration of function 'enic_rfs_flw_tbl_init' [-Werror=implicit-function-declaration]
drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_stop':
drivers/net/ethernet/cisco/enic/enic_main.c:1630:2: error: implicit declaration of function 'enic_rfs_flw_tbl_free' [-Werror=implicit-function-declaration]

Introduced in commit a145df23ef32c7b933875f334ba28791ee75766e ("enic: Add
Accelerated RFS support").

Dummy functions are provided, but their prototypes are missing, causing the
build failure.  Provide dummy static inline functions instead to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
kisskb.ellerman.id.au/kisskb/buildresult/11381101/
---
 drivers/net/ethernet/cisco/enic/enic_clsf.c | 10 ----------
 drivers/net/ethernet/cisco/enic/enic_clsf.h |  3 +++
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index c2322adfccdc..bc451baac4cd 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -266,14 +266,4 @@ ret_unlock:
 	return res;
 }
 
-#else
-
-void enic_rfs_flw_tbl_init(struct enic *enic)
-{
-}
-
-void enic_rfs_flw_tbl_free(struct enic *enic)
-{
-}
-
 #endif /* CONFIG_RFS_ACCEL */
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.h b/drivers/net/ethernet/cisco/enic/enic_clsf.h
index 76a85bb0bb73..d572704cd117 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.h
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.h
@@ -14,6 +14,9 @@ void enic_rfs_flw_tbl_init(struct enic *enic);
 void enic_rfs_flw_tbl_free(struct enic *enic);
 int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 		       u16 rxq_index, u32 flow_id);
+#else
+static inline void enic_rfs_flw_tbl_init(struct enic *enic) {}
+static inline void enic_rfs_flw_tbl_free(struct enic *enic) {}
 #endif /* CONFIG_RFS_ACCEL */
 
 #endif /* _ENIC_CLSF_H_ */
-- 
1.9.1
