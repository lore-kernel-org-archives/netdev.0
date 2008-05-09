From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: [PATCH ] [NIU] Redo: Determine the # of ports from the card's VPD data
Date: Fri, 09 May 2008 11:21:59 -0700
Message-ID: <48249647.2000505@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:54001 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbYEISVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 14:21:35 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m49ILXpA015850
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 11:21:33 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K0M00A015H9NS00@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Fri,
 09 May 2008 11:21:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Determine the number of physical ports from the card's VPD data.
Previous fix failed on Maramba platform which doesn't have the
"board-model" property. This fix uses the "model" property which
exists on all cards and Neptune based motherboards.

cstyle cleanup included.


Signed-off-by: Matheos <matheos.worku@sun.com>
---
  drivers/net/niu.c |   53 
+++++++++++++++++++++--------------------------------
  1 files changed, 21 insertions(+), 32 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 57cfd72..918f802 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -865,7 +865,6 @@ static int link_status_1g_serdes(struct niu *np, int 
*link_up_p)
  	return 0;
  }

-
  static int link_status_10g_serdes(struct niu *np, int *link_up_p)
  {
  	unsigned long flags;
@@ -900,7 +899,6 @@ static int link_status_10g_serdes(struct niu *np, 
int *link_up_p)
  	return 0;
  }

-
  static int link_status_1g_rgmii(struct niu *np, int *link_up_p)
  {
  	struct niu_link_config *lp = &np->link_config;
@@ -957,7 +955,6 @@ out:
  	return err;
  }

-
  static int bcm8704_reset(struct niu *np)
  {
  	int err, limit;
@@ -1357,8 +1354,6 @@ static int mii_reset(struct niu *np)
  	return 0;
  }

-
-
  static int xcvr_init_1g_rgmii(struct niu *np)
  {
  	int err;
@@ -1419,7 +1414,6 @@ static int xcvr_init_1g_rgmii(struct niu *np)
  	return 0;
  }

-
  static int mii_init_common(struct niu *np)
  {
  	struct niu_link_config *lp = &np->link_config;
@@ -7008,31 +7002,20 @@ static int __devinit 
niu_phy_type_prop_decode(struct niu *np,
  	return 0;
  }

-/* niu board models have a trailing dash version incremented
- * with HW rev change. Need to ingnore the  dash version while
- * checking for match
- *
- * for example, for the 10G card the current vpd.board_model
- * is 501-5283-04, of which -04 is the  dash version and have
- * to be ignored
- */
-static int niu_board_model_match(struct niu *np, const char *model)
-{
-	return !strncmp(np->vpd.board_model, model, strlen(model));
-}
-
  static int niu_pci_vpd_get_nports(struct niu *np)
  {
  	int ports = 0;

-	if ((niu_board_model_match(np, NIU_QGC_LP_BM_STR)) ||
-	    (niu_board_model_match(np, NIU_QGC_PEM_BM_STR)) ||
-	    (niu_board_model_match(np, NIU_ALONSO_BM_STR))) {
+	if ((!strcmp(np->vpd.model, NIU_QGC_LP_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_QGC_PEM_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_MARAMBA_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR))) {
  		ports = 4;
-	} else if ((niu_board_model_match(np, NIU_2XGF_LP_BM_STR)) ||
-		   (niu_board_model_match(np, NIU_2XGF_PEM_BM_STR)) ||
-		   (niu_board_model_match(np, NIU_FOXXY_BM_STR)) ||
-		   (niu_board_model_match(np, NIU_2XGF_MRVL_BM_STR))) {
+	} else if ((!strcmp(np->vpd.model, NIU_2XGF_LP_MDL_STR)) ||
+		   (!strcmp(np->vpd.model, NIU_2XGF_PEM_MDL_STR)) ||
+		   (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) ||
+		   (!strcmp(np->vpd.model, NIU_2XGF_MRVL_MDL_STR))) {
  		ports = 2;
  	}

@@ -7053,8 +7036,8 @@ static void __devinit niu_pci_vpd_validate(struct 
niu *np)
  		return;
  	}

-	if (!strcmp(np->vpd.model, "SUNW,CP3220") ||
-	    !strcmp(np->vpd.model, "SUNW,CP3260")) {
+	if (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR) ||
+	    !strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) {
  		np->flags |= NIU_FLAGS_10G;
  		np->flags &= ~NIU_FLAGS_FIBER;
  		np->flags |= NIU_FLAGS_XCVR_SERDES;
@@ -7065,7 +7048,7 @@ static void __devinit niu_pci_vpd_validate(struct 
niu *np)
  		}
  		if (np->flags & NIU_FLAGS_10G)
  			 np->mac_xcvr = MAC_XCVR_XPCS;
-	} else if (niu_board_model_match(np, NIU_FOXXY_BM_STR)) {
+	} else if (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) {
  		np->flags |= (NIU_FLAGS_10G | NIU_FLAGS_FIBER |
  			      NIU_FLAGS_HOTPLUG_PHY);
  	} else if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
@@ -7541,8 +7524,8 @@ static int __devinit walk_phys(struct niu *np, 
struct niu_parent *parent)
  	u32 val;
  	int err;

-	if (!strcmp(np->vpd.model, "SUNW,CP3220") ||
-	    !strcmp(np->vpd.model, "SUNW,CP3260")) {
+	if (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR) ||
+	    !strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) {
  		num_10g = 0;
  		num_1g = 2;
  		parent->plat_type = PLAT_TYPE_ATCA_CP3220;
@@ -7551,7 +7534,7 @@ static int __devinit walk_phys(struct niu *np, 
struct niu_parent *parent)
  		       phy_encode(PORT_TYPE_1G, 1) |
  		       phy_encode(PORT_TYPE_1G, 2) |
  		       phy_encode(PORT_TYPE_1G, 3));
-	} else if (niu_board_model_match(np, NIU_FOXXY_BM_STR)) {
+	} else if (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) {
  		num_10g = 2;
  		num_1g = 0;
  		parent->num_ports = 2;
@@ -7946,6 +7929,7 @@ static int __devinit niu_get_of_props(struct niu *np)
  	struct device_node *dp;
  	const char *phy_type;
  	const u8 *mac_addr;
+	const char *model;
  	int prop_len;

  	if (np->parent->plat_type == PLAT_TYPE_NIU)
@@ -8000,6 +7984,11 @@ static int __devinit niu_get_of_props(struct niu *np)

  	memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);

+	model = of_get_property(dp, "model", &prop_len);
+
+	if (model)
+		strcpy(np->vpd.model, model);
+
  	return 0;
  #else
  	return -EINVAL;
-- 
1.5.2


