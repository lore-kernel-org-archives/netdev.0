From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40evf: Add longer wait after remove module
Date: Tue,  5 Apr 2016 20:36:02 -0700
Message-ID: <1459913769-56510-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61852 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760840AbcDFDg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:27 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Upon module remove, wait a little longer after requesting a reset before
checking to see if the firmware responded. This change prevents double
resets when the firmware is busy.

Change-ID: Ieedc988ee82fac1f32a074bf4d9e4dba426bfa58
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 2d018b4..6561a33 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2854,11 +2854,11 @@ static void i40evf_remove(struct pci_dev *pdev)
 	adapter->state = __I40EVF_REMOVE;
 	adapter->aq_required = 0;
 	i40evf_request_reset(adapter);
-	msleep(20);
+	msleep(50);
 	/* If the FW isn't responding, kick it once, but only once. */
 	if (!i40evf_asq_done(hw)) {
 		i40evf_request_reset(adapter);
-		msleep(20);
+		msleep(50);
 	}
 
 	if (adapter->msix_entries) {
-- 
2.5.5
