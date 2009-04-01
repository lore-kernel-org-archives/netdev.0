From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/9] ixgbe: Fix DCB netlink layer for 82599 to enable Priority
	Flow Control
Date: Wed, 01 Apr 2009 00:33:25 -0700
Message-ID: <20090401073325.3749.28376.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:58941
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760580AbZDAHdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:33:44 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The priority flow control settings from the netlink layer aren't taking
effect in the base driver.  The boolean pfc_mode_enable in the dcb_config
struct isn't being set, so the hardware configuration code is never
reached.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 0a8731f..bd0a0c2 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -90,6 +90,8 @@ int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 			src_dcb_cfg->tc_config[i - DCB_PFC_UP_ATTR_0].dcb_pfc;
 	}
 
+	dst_dcb_cfg->pfc_mode_enable = src_dcb_cfg->pfc_mode_enable;
+
 	return 0;
 }
 
@@ -298,8 +300,10 @@ static void ixgbe_dcbnl_set_pfc_cfg(struct net_device *netdev, int priority,
 
 	adapter->temp_dcb_cfg.tc_config[priority].dcb_pfc = setting;
 	if (adapter->temp_dcb_cfg.tc_config[priority].dcb_pfc !=
-	    adapter->dcb_cfg.tc_config[priority].dcb_pfc)
+	    adapter->dcb_cfg.tc_config[priority].dcb_pfc) {
 		adapter->dcb_set_bitmap |= BIT_PFC;
+		adapter->temp_dcb_cfg.pfc_mode_enable = true;
+	}
 }
 
 static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,

