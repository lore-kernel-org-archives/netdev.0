From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e/i40evf: set proper default for ITR registers
Date: Wed, 21 May 2014 05:01:06 -0700
Message-ID: <1400673673-31626-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21038 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350AbaEUMB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:29 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Ethtool consistently reports 0 values for our ITR settings because
we never actually set them. Fix this by setting the default values
to the specified default values.

Change-ID: I2832406a66f7140f2b1230945d6ff6cbf77467c8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 4 ++++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e399f9b..e965cc5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6368,6 +6368,10 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    I40E_FLAG_MSIX_ENABLED    |
 		    I40E_FLAG_RX_1BUF_ENABLED;
 
+	/* Set default ITR */
+	pf->rx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF;
+	pf->tx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_TX_DEF;
+
 	/* Depending on PF configurations, it is possible that the RSS
 	 * maximum might end up larger than the available queues
 	 */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 6455280..13989ef 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2122,8 +2122,10 @@ static void i40evf_init_task(struct work_struct *work)
 	adapter->vsi.back = adapter;
 	adapter->vsi.base_vector = 1;
 	adapter->vsi.work_limit = I40E_DEFAULT_IRQ_WORK;
-	adapter->vsi.rx_itr_setting = I40E_ITR_DYNAMIC;
-	adapter->vsi.tx_itr_setting = I40E_ITR_DYNAMIC;
+	adapter->vsi.rx_itr_setting = (I40E_ITR_DYNAMIC |
+				       ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
+	adapter->vsi.tx_itr_setting = (I40E_ITR_DYNAMIC |
+				       ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
 	adapter->vsi.netdev = adapter->netdev;
 
 	if (!adapter->netdev_registered) {
-- 
1.9.0
