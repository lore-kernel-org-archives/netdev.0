From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] ixgbe: fix default mac->ops.setup_link for X550EM
Date: Mon, 25 Apr 2016 05:44:17 -0700
Message-ID: <1461588269-128728-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139AbcDYMoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:32 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

X550EM_a/x did not have a default value for mac->ops.setup_link which
was causing link issues for backplane devices.

This patch sets mac->ops.setup_link to ixgbe_setup_mac_link_X540 for
X550EM_a/x which is also default for X550. This will result in
mac->ops.setup_link calling the link setup function for the respective
PHY type in case we do not need a special function to deal with it.

Reported-by: Ken Cox <jkc@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index c71e93e..ea25f00 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2908,7 +2908,7 @@ static const struct ixgbe_mac_operations mac_ops_X550EM_x = {
 	.get_media_type		= &ixgbe_get_media_type_X550em,
 	.get_san_mac_addr	= NULL,
 	.get_wwn_prefix		= NULL,
-	.setup_link		= NULL, /* defined later */
+	.setup_link		= &ixgbe_setup_mac_link_X540,
 	.get_link_capabilities	= &ixgbe_get_link_capabilities_X550em,
 	.get_bus_info		= &ixgbe_get_bus_info_X550em,
 	.setup_sfp		= ixgbe_setup_sfp_modules_X550em,
@@ -2926,7 +2926,7 @@ static struct ixgbe_mac_operations mac_ops_x550em_a = {
 	.get_media_type		= ixgbe_get_media_type_X550em,
 	.get_san_mac_addr	= NULL,
 	.get_wwn_prefix		= NULL,
-	.setup_link		= NULL, /* defined later */
+	.setup_link		= &ixgbe_setup_mac_link_X540,
 	.get_link_capabilities	= ixgbe_get_link_capabilities_X550em,
 	.get_bus_info		= ixgbe_get_bus_info_X550em,
 	.setup_sfp		= ixgbe_setup_sfp_modules_X550em,
-- 
2.5.5
