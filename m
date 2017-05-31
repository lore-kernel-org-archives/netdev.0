From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbevf: Resolve warnings for -Wimplicit-fallthrough
Date: Wed, 31 May 2017 14:19:31 -0700
Message-ID: <20170531211936.63417-11-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:4561 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751153AbdEaVTv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:51 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Additions to gcc 7 now warn whenever a switch statement falls through
implicitly.  This patch adds explicit fall through comments to address the
following warnings:

drivers/net/ethernet/intel/ixgbevf/vf.c: In function ‘ixgbevf_get_reta_locked’:
drivers/net/ethernet/intel/ixgbevf/vf.c:336:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
   if (hw->mac.type < ixgbe_mac_X550_vf)
      ^
drivers/net/ethernet/intel/ixgbevf/vf.c:338:2: note: here
  default:
  ^~~~~~~
drivers/net/ethernet/intel/ixgbevf/vf.c: In function ‘ixgbevf_get_rss_key_locked’:
drivers/net/ethernet/intel/ixgbevf/vf.c:402:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
   if (hw->mac.type < ixgbe_mac_X550_vf)
      ^
drivers/net/ethernet/intel/ixgbevf/vf.c:404:2: note: here
  default:
  ^~~~~~~

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index b6d0c01eab10..0c25006ce9af 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -335,6 +335,7 @@ int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues)
 	case ixgbe_mbox_api_12:
 		if (hw->mac.type < ixgbe_mac_X550_vf)
 			break;
+		/* fall through */
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -401,6 +402,7 @@ int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
 	case ixgbe_mbox_api_12:
 		if (hw->mac.type < ixgbe_mac_X550_vf)
 			break;
+		/* fall through */
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.12.2
