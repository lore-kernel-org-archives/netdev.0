From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e: Issue "Stop LLDP" command for firmware older than v4.3
Date: Thu, 15 Jan 2015 04:19:22 -0800
Message-ID: <1421324368-6860-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753451AbbAOMTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:36 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Disable firmware LLDP agent for NICs with firmware version lower than
v4.3. Added a message when driver disables the firmware LLDP agent on
such NICs.

Change-ID: Ia8abf89439c70cb50e23db82753d7d282265506b
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0cc0266..d7efc1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9245,6 +9245,16 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_configure_lan_hmc;
 	}
 
+	/* Disable LLDP for NICs that have firmware versions lower than v4.3.
+	 * Ignore error return codes because if it was already disabled via
+	 * hardware settings this will fail
+	 */
+	if (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 3)) ||
+	    (pf->hw.aq.fw_maj_ver < 4)) {
+		dev_info(&pdev->dev, "Stopping firmware LLDP agent.\n");
+		i40e_aq_stop_lldp(hw, true, NULL);
+	}
+
 	i40e_get_mac_addr(hw, hw->mac.addr);
 	if (!is_valid_ether_addr(hw->mac.addr)) {
 		dev_info(&pdev->dev, "invalid MAC address %pM\n", hw->mac.addr);
-- 
1.9.3
