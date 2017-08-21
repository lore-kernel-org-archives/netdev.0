From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: ethernet: make ptp_clock_info const
Date: Mon, 21 Aug 2017 22:36:50 +0530
Message-ID: <1503335210-16179-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, nicolas.ferre@microchip.com,
        richardcochran@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, cmetcalf@mellanox.com,
        adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only used in a copy operation.
Done using Coccinelle.

@match disable optional_qualifier@
identifier s;
@@
static struct ptp_clock_info s = {...};

@ref@
position p;
identifier match.s;
@@
s@p

@good1@
position ref.p;
identifier match.s,f,c;
expression e;
@@
(
e = s@p
|
e = s@p.f
|
c(...,s@p.f,...)
|
c(...,s@p,...)
)

@bad depends on  !good1@
position ref.p;
identifier match.s;
@@
s@p

@depends on forall !bad disable optional_qualifier@
identifier match.s;
@@
static
+ const
struct ptp_clock_info s;

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c              | 2 +-
 drivers/net/ethernet/cadence/macb_ptp.c          | 2 +-
 drivers/net/ethernet/freescale/gianfar_ptp.c     | 2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c | 2 +-
 drivers/net/ethernet/ti/cpts.c                   | 2 +-
 drivers/net/ethernet/tile/tilegx.c               | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index a9ac58c..a251de8 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -986,7 +986,7 @@ static int bfin_ptp_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info bfin_ptp_caps = {
+static const struct ptp_clock_info bfin_ptp_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "BF518 clock",
 	.max_adj	= 0,
diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
index 67cca08..2220c77 100755
--- a/drivers/net/ethernet/cadence/macb_ptp.c
+++ b/drivers/net/ethernet/cadence/macb_ptp.c
@@ -192,7 +192,7 @@ static int gem_ptp_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info gem_ptp_caps_template = {
+static const struct ptp_clock_info gem_ptp_caps_template = {
 	.owner		= THIS_MODULE,
 	.name		= GEM_PTP_TIMER_NAME,
 	.max_adj	= 0,
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 721be13..5441142 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -411,7 +411,7 @@ static int ptp_gianfar_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info ptp_gianfar_caps = {
+static const struct ptp_clock_info ptp_gianfar_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "gianfar clock",
 	.max_adj	= 512000,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index d71bd80..e471a90 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -152,7 +152,7 @@ static int stmmac_enable(struct ptp_clock_info *ptp,
 }
 
 /* structure describing a PTP hardware clock */
-static struct ptp_clock_info stmmac_ptp_clock_ops = {
+static const struct ptp_clock_info stmmac_ptp_clock_ops = {
 	.owner = THIS_MODULE,
 	.name = "stmmac_ptp_clock",
 	.max_adj = 62500000,
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index c2121d2..e7b76f6 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -298,7 +298,7 @@ static long cpts_overflow_check(struct ptp_clock_info *ptp)
 	return (long)delay;
 }
 
-static struct ptp_clock_info cpts_info = {
+static const struct ptp_clock_info cpts_info = {
 	.owner		= THIS_MODULE,
 	.name		= "CTPS timer",
 	.max_adj	= 1000000,
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index aec9538..c00102b 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -873,7 +873,7 @@ static int ptp_mpipe_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info ptp_mpipe_caps = {
+static const struct ptp_clock_info ptp_mpipe_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "mPIPE clock",
 	.max_adj	= 999999999,
-- 
1.9.1
