From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbe: Fix gso_max_size for 82599 when DCB is
	enabled
Date: Fri, 06 Nov 2009 14:55:38 -0800
Message-ID: <20091106225526.28063.83720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:44509
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760005AbZKFWzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 17:55:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The 32k gso_max_size when DCB is enabled is for 82598 only, not for 82599.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cbb143c..26fc1df 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2471,7 +2471,10 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_restore_vlan(adapter);
 #ifdef CONFIG_IXGBE_DCB
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		netif_set_gso_max_size(netdev, 32768);
+		if (hw->mac.type == ixgbe_mac_82598EB)
+			netif_set_gso_max_size(netdev, 32768);
+		else
+			netif_set_gso_max_size(netdev, 65536);
 		ixgbe_configure_dcb(adapter);
 	} else {
 		netif_set_gso_max_size(netdev, 65536);

