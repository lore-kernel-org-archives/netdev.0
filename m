From: panduranga_mallireddy@ti.com
Subject: [PATCH 5/5] OMAP: hsmmc: Enable MMC4 and MMC5 on OMAP4 platforms
Date: Mon, 14 Feb 2011 02:19:18 -0500
Message-ID: <1297667958-22377-6-git-send-email-panduranga_mallireddy@ti.com>
References: <1297667958-22377-1-git-send-email-panduranga_mallireddy@ti.com>
 <1297667958-22377-2-git-send-email-panduranga_mallireddy@ti.com>
 <1297667958-22377-3-git-send-email-panduranga_mallireddy@ti.com>
 <1297667958-22377-4-git-send-email-panduranga_mallireddy@ti.com>
 <1297667958-22377-5-git-send-email-panduranga_mallireddy@ti.com>
Cc: ohad@wizery.com, benzyg@ti.com, pradeepgurumath@ti.com,
	vishalm@ti.com, x-boudet@ti.com, naveen_jain@ti.com,
	pavan_savoy@ti.com, manjunatha_halli@ti.com, tony@atomide.com,
	cjb@laptop.org, Kishore Kadiyala <kishore.kadiyala@ti.com>,
	Panduranga Mallireddy <panduranga_mallireddy@ti.com>
To: coelho@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1297667958-22377-5-git-send-email-panduranga_mallireddy@ti.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kishore Kadiyala <kishore.kadiyala@ti.com>

OMAP4 supports up to 5 MMC controllers, but only 3 of these were
initialized. MMC5 is used by wl12xx chip. So initialize MMC4 and MMC5.

Signed-off-by: Kishore Kadiyala <kishore.kadiyala@ti.com>
Signed-off-by: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
---
 arch/arm/mach-omap2/hsmmc.c   |    5 +++++
 drivers/mmc/host/omap_hsmmc.c |   24 ++++++++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mach-omap2/hsmmc.c b/arch/arm/mach-omap2/hsmmc.c
index 8f1a484..3c0809f 100644
--- a/arch/arm/mach-omap2/hsmmc.c
+++ b/arch/arm/mach-omap2/hsmmc.c
@@ -348,6 +348,11 @@ void __init omap2_hsmmc_init(struct omap2_hsmmc_info *controllers)
 				mmc->slots[0].after_set_reg = NULL;
 			}
 			break;
+		case 4:
+		case 5:
+			mmc->slots[0].before_set_reg = NULL;
+			mmc->slots[0].after_set_reg = NULL;
+			break;
 		default:
 			pr_err("MMC%d configuration not supported!\n", c->mmc);
 			kfree(mmc);
diff --git a/drivers/mmc/host/omap_hsmmc.c b/drivers/mmc/host/omap_hsmmc.c
index f59f8da..2525071 100644
--- a/drivers/mmc/host/omap_hsmmc.c
+++ b/drivers/mmc/host/omap_hsmmc.c
@@ -260,7 +260,7 @@ static int omap_hsmmc_1_set_power(struct device *dev, int slot, int power_on,
 	return ret;
 }
 
-static int omap_hsmmc_23_set_power(struct device *dev, int slot, int power_on,
+static int omap_hsmmc_235_set_power(struct device *dev, int slot, int power_on,
 				   int vdd)
 {
 	struct omap_hsmmc_host *host =
@@ -316,6 +316,12 @@ static int omap_hsmmc_23_set_power(struct device *dev, int slot, int power_on,
 	return ret;
 }
 
+static int omap_hsmmc_4_set_power(struct device *dev, int slot, int power_on,
+					int vdd)
+{
+	return 0;
+}
+
 static int omap_hsmmc_1_set_sleep(struct device *dev, int slot, int sleep,
 				  int vdd, int cardsleep)
 {
@@ -326,7 +332,7 @@ static int omap_hsmmc_1_set_sleep(struct device *dev, int slot, int sleep,
 	return regulator_set_mode(host->vcc, mode);
 }
 
-static int omap_hsmmc_23_set_sleep(struct device *dev, int slot, int sleep,
+static int omap_hsmmc_235_set_sleep(struct device *dev, int slot, int sleep,
 				   int vdd, int cardsleep)
 {
 	struct omap_hsmmc_host *host =
@@ -365,6 +371,12 @@ static int omap_hsmmc_23_set_sleep(struct device *dev, int slot, int sleep,
 		return regulator_enable(host->vcc_aux);
 }
 
+static int omap_hsmmc_4_set_sleep(struct device *dev, int slot, int sleep,
+					int vdd, int cardsleep)
+{
+	return 0;
+}
+
 static int omap_hsmmc_reg_get(struct omap_hsmmc_host *host)
 {
 	struct regulator *reg;
@@ -379,10 +391,14 @@ static int omap_hsmmc_reg_get(struct omap_hsmmc_host *host)
 		break;
 	case OMAP_MMC2_DEVID:
 	case OMAP_MMC3_DEVID:
+	case OMAP_MMC5_DEVID:
 		/* Off-chip level shifting, or none */
-		mmc_slot(host).set_power = omap_hsmmc_23_set_power;
-		mmc_slot(host).set_sleep = omap_hsmmc_23_set_sleep;
+		mmc_slot(host).set_power = omap_hsmmc_235_set_power;
+		mmc_slot(host).set_sleep = omap_hsmmc_235_set_sleep;
 		break;
+	case OMAP_MMC4_DEVID:
+		mmc_slot(host).set_power = omap_hsmmc_4_set_power;
+		mmc_slot(host).set_sleep = omap_hsmmc_4_set_sleep;
 	default:
 		pr_err("MMC%d configuration not supported!\n", host->id);
 		return -EINVAL;
-- 
1.5.6.3

