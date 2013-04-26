From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: add mac type to the version in ethtool_regs
Date: Thu, 25 Apr 2013 21:57:11 -0700
Message-ID: <1366952231-16727-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45056 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868Ab3DZE5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:22 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds the mac type to the version in ethtool_regs.

This will make it easier to check the mac type when dumping registers with
ethtool. The drawback of this is that older versions of ethtool will only
be able to dump in hex format for 82599 and above  when used with the updated
driver.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 509d3ae..d375472 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -440,7 +440,8 @@ static void ixgbe_get_regs(struct net_device *netdev,
 
 	memset(p, 0, IXGBE_REGS_LEN * sizeof(u32));
 
-	regs->version = (1 << 24) | hw->revision_id << 16 | hw->device_id;
+	regs->version = hw->mac.type << 24 | hw->revision_id << 16 |
+			hw->device_id;
 
 	/* General Registers */
 	regs_buff[0] = IXGBE_READ_REG(hw, IXGBE_CTRL);
-- 
1.7.11.7
