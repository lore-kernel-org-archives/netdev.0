From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] fm10k: Report MAC address on driver load
Date: Tue, 15 Sep 2015 17:36:34 -0700
Message-ID: <1442363803-47237-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbbIPAgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:48 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change adds the MAC address to the list of values recorded on driver
load.  The MAC address represents the serial number of the unit and allows
us to track the value should a card be replaced in a system.

The log message should now be similar in output to that of ixgbe.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index db237b7..9f2b2f1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1905,6 +1905,9 @@ static int fm10k_probe(struct pci_dev *pdev,
 	/* print warning for non-optimal configurations */
 	fm10k_slot_warn(interface);
 
+	/* report MAC address for logging */
+	dev_info(&pdev->dev, "%pM\n", netdev->dev_addr);
+
 	/* enable SR-IOV after registering netdev to enforce PF/VF ordering */
 	fm10k_iov_configure(pdev, 0);
 
-- 
2.4.3
