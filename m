From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 14/26] et131x: config is already zeroed
Date: Tue, 25 Aug 2009 15:59:48 +0100
Message-ID: <20090825145942.16176.16307.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47795 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755339AbZHYPFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:05:10 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapter was cleared by netdev allocation so any zero defaults do not need
writing.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et131x_config.c |   75 ++++++++------------------------
 1 files changed, 18 insertions(+), 57 deletions(-)


diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/et131x/et131x_config.c
index 358e6f6..cde727d 100644
--- a/drivers/staging/et131x/et131x_config.c
+++ b/drivers/staging/et131x/et131x_config.c
@@ -101,58 +101,30 @@ extern dbg_info_t *et131x_dbginfo;
 #endif /* CONFIG_ET131X_DEBUG */
 
 /* Defines for Parameter Default/Min/Max vaules */
-#define PARM_SPEED_DUPLEX_DEF   0
 #define PARM_SPEED_DUPLEX_MIN   0
 #define PARM_SPEED_DUPLEX_MAX   5
 
-#define PARM_FLOW_CTL_DEF       0
-#define PARM_FLOW_CTL_MIN       0
-#define PARM_FLOW_CTL_MAX       3
-
-#define PARM_JUMBO_PKT_DEF      1514
-#define PARM_JUMBO_PKT_MIN      1514
-#define PARM_JUMBO_PKT_MAX      9216
-
-#define PARM_PHY_COMA_DEF       0
-#define PARM_PHY_COMA_MIN       0
-#define PARM_PHY_COMA_MAX       1
-
-#define PARM_SC_GAIN_DEF        7
-#define PARM_SC_GAIN_MIN        0
-#define PARM_SC_GAIN_MAX        7
-
-#define PARM_PM_WOL_DEF         0
-#define PARM_PM_WOL_MIN         0
-#define PARM_PM_WOL_MAX         1
-
-#define PARM_NMI_DISABLE_DEF    0
-#define PARM_NMI_DISABLE_MIN    0
-#define PARM_NMI_DISABLE_MAX    2
-
-
-
 /* Module parameter for disabling NMI
- * et131x_speed_set :
+ * et131x_nmi_disable :
+ * Disable NMI (0-2) [0]
+ *  0 :
+ *  1 :
+ *  2 :
+ */
+static u32 et131x_nmi_disable;	/* 0-2 */
+module_param(et131x_nmi_disable, uint, 0);
+MODULE_PARM_DESC(et131x_nmi_disable, "Disable NMI (0-2) [0]");
+
+/* Module parameter for manual speed setting
  * Set Link speed and dublex manually (0-5)  [0]
  *  1 : 10Mb   Half-Duplex
  *  2 : 10Mb   Full-Duplex
  *  3 : 100Mb  Half-Duplex
  *  4 : 100Mb  Full-Duplex
  *  5 : 1000Mb Full-Duplex
- *  0 : Auto Speed Auto Dublex // default
- */
-static u32 et131x_nmi_disable = PARM_NMI_DISABLE_DEF;
-module_param(et131x_nmi_disable, uint, 0);
-MODULE_PARM_DESC(et131x_nmi_disable, "Disable NMI (0-2) [0]");
-
-/* Module parameter for manual speed setting
- * et131x_nmi_disable :
- * Disable NMI (0-2) [0]
- *  0 :
- *  1 :
- *  2 :
+ *  0 : Auto Speed Auto Duplex // default
  */
-static u32 et131x_speed_set = PARM_SPEED_DUPLEX_DEF;
+static u32 et131x_speed_set;
 module_param(et131x_speed_set, uint, 0);
 MODULE_PARM_DESC(et131x_speed_set,
 		"Set Link speed and dublex manually (0-5)  [0] \n  1 : 10Mb   Half-Duplex \n  2 : 10Mb   Full-Duplex \n  3 : 100Mb  Half-Duplex \n  4 : 100Mb  Full-Duplex \n  5 : 1000Mb Full-Duplex \n 0 : Auto Speed Auto Dublex");
@@ -175,33 +147,22 @@ void et131x_config_parse(struct et131x_adapter *etdev)
 
 	DBG_ENTER(et131x_dbginfo);
 
-	etdev->SpeedDuplex = et131x_speed_set;
-
 	if (et131x_speed_set < PARM_SPEED_DUPLEX_MIN ||
 	    et131x_speed_set > PARM_SPEED_DUPLEX_MAX) {
 	    	dev_warn(&etdev->pdev->dev, "invalid speed setting ignored.\n");
-	    	et131x_speed_set = PARM_SPEED_DUPLEX_DEF;
+	    	et131x_speed_set = 0;
 	}
-	else if (et131x_speed_set != PARM_SPEED_DUPLEX_DEF)
+	else if (et131x_speed_set)
 		DBG_VERBOSE(et131x_dbginfo, "Speed set manually to : %d \n",
 			    et131x_speed_set);
 
-	/*  etdev->SpeedDuplex            = PARM_SPEED_DUPLEX_DEF; */
-
-	etdev->RegistryFlowControl = PARM_FLOW_CTL_DEF;
-	etdev->RegistryJumboPacket = PARM_JUMBO_PKT_DEF;
-	etdev->RegistryPhyComa = PARM_PHY_COMA_DEF;
-
-	if (et131x_nmi_disable != PARM_NMI_DISABLE_DEF)
-		etdev->RegistryNMIDisable = et131x_nmi_disable;
-	else
-		etdev->RegistryNMIDisable = PARM_NMI_DISABLE_DEF;
+	etdev->SpeedDuplex = et131x_speed_set;
+	etdev->RegistryJumboPacket = 1514;	/* 1514-9216 */
 
-	etdev->RegistryPhyLoopbk = 0;	/* 0 off 1 on */
+	etdev->RegistryNMIDisable = et131x_nmi_disable;
 
 	/* Set the MAC address to a default */
 	memcpy(etdev->CurrentAddress, default_mac, ETH_ALEN);
-	etdev->bOverrideAddress = false;
 
 	/* Decode SpeedDuplex
 	 *

