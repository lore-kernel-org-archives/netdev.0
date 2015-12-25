From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: fix write to VLVFB in ixgbe_clear_vf_vlans()
Date: Thu, 24 Dec 2015 21:29:55 -0800
Message-ID: <1451021396-68858-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55539 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749AbbLYFaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 00:30:00 -0500
In-Reply-To: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix the write to the VLVFB register in ixgbe_clear_vf_vlans() where
word is the actual offset of the register and not the index for the
IXGBE_VLVFB macro.

This was causing PCI AER errors on my system.

Fixes: 4c7f35f679f592804736f9303051257de2c9f021
("ixgbe: Clean stale VLANs when changing port VLAN or resetting")

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index eeff3d0..fd918da 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -640,7 +640,7 @@ update_vlvf:
 		IXGBE_WRITE_REG(hw, IXGBE_VLVF(i), 0);
 update_vlvfb:
 		/* clear pool bits */
-		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(word), vlvfb);
+		IXGBE_WRITE_REG(hw, word, vlvfb);
 	}
 }
 
-- 
2.5.0
