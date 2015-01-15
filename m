From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] i40e: fix proc/int descriptions
Date: Thu, 15 Jan 2015 04:19:14 -0800
Message-ID: <1421324368-6860-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505AbbAOMTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:32 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where the /proc/interrupts descriptions
from the msix configuration were truncating the needed bus info,
making it hard to distinguish configuration from port to port.
This patch increases the string buffer size in order to allow the
full data to be displayed and sync's the text formatting of the misc
and fdir interrupt names

Change-ID: Ib01d6c61fb3f4ac70fbdf5bcc520b22638ea54b7
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f3b036d..cd34d9b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4845,7 +4845,7 @@ static int i40e_open(struct net_device *netdev)
 int i40e_vsi_open(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
-	char int_name[IFNAMSIZ];
+	char int_name[IFNAMSIZ + 9];
 	int err;
 
 	/* allocate descriptors */
@@ -4879,7 +4879,7 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 			goto err_set_queues;
 
 	} else if (vsi->type == I40E_VSI_FDIR) {
-		snprintf(int_name, sizeof(int_name) - 1, "%s-%s-fdir",
+		snprintf(int_name, sizeof(int_name) - 1, "%s-%s:fdir",
 			 dev_driver_string(&pf->pdev->dev),
 			 dev_name(&pf->pdev->dev));
 		err = i40e_vsi_request_irq(vsi, int_name);
-- 
1.9.3
