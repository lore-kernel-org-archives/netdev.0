From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e: fix netdev_stat macro definition
Date: Fri, 21 Nov 2014 21:54:59 -0800
Message-ID: <1416635708-4765-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50713 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784AbaKVFzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:16 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The old xxx_NETDEV_STAT() macro was defined long before the newer
rtnl_link_stats64 came into being, and just never got updated.  Since we're
using rtnl_link_stats64 in other parts of the driver, we should use it
here as well.  We've just been lucky that the field definitions are the
same sizes.

Change-ID: I19fc71619905700235dcdf0d3c8153aec81d36de
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 4053b34..fcd815d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -40,8 +40,9 @@ struct i40e_stats {
 	.sizeof_stat = FIELD_SIZEOF(_type, _stat), \
 	.stat_offset = offsetof(_type, _stat) \
 }
+
 #define I40E_NETDEV_STAT(_net_stat) \
-		I40E_STAT(struct net_device_stats, #_net_stat, _net_stat)
+		I40E_STAT(struct rtnl_link_stats64, #_net_stat, _net_stat)
 #define I40E_PF_STAT(_name, _stat) \
 		I40E_STAT(struct i40e_pf, _name, _stat)
 #define I40E_VSI_STAT(_name, _stat) \
-- 
1.9.3
