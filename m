From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/20] i40e: Driver prints log message on link speed change
Date: Tue,  6 Dec 2016 23:33:35 -0800
Message-ID: <20161207073354.88568-2-jeffrey.t.kirsher@intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Cc: Filip Sadowski <filip.sadowski@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34826 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752496AbcLGHeq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 02:34:46 -0500
In-Reply-To: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filip Sadowski <filip.sadowski@intel.com>

This patch makes the driver log link speed change. Before applying the
patch link messages were printed only on state change. Now message is
printed when link is brought up or down and when speed changes.

Change-ID: Ifbee14b4b16c24967450b3cecac6e8351dcc8f74
Signed-off-by: Filip Sadowski <filip.sadowski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4cb8fb3..06e3c23 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -596,6 +596,7 @@ struct i40e_vsi {
 	u16 veb_idx;		/* index of VEB parent */
 	struct kobject *kobj;	/* sysfs object */
 	bool current_isup;	/* Sync 'link up' logging */
+	enum i40e_aq_link_speed current_speed;	/* Sync link speed logging */
 
 	void *priv;	/* client driver data reference. */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5777e49..4534d41 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5225,12 +5225,16 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
  */
 void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 {
+	enum i40e_aq_link_speed new_speed;
 	char *speed = "Unknown";
 	char *fc = "Unknown";
 
-	if (vsi->current_isup == isup)
+	new_speed = vsi->back->hw.phy.link_info.link_speed;
+
+	if ((vsi->current_isup == isup) && (vsi->current_speed == new_speed))
 		return;
 	vsi->current_isup = isup;
+	vsi->current_speed = new_speed;
 	if (!isup) {
 		netdev_info(vsi->netdev, "NIC Link is Down\n");
 		return;
-- 
2.9.3
