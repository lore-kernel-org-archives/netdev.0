From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: Fix PCI bus reporting on driver load for
	82598 after 82599 merge
Date: Thu, 19 Mar 2009 04:23:29 -0700
Message-ID: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:50197
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752338AbZCSLXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:23:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

82598's PCI bus reporting on driver load was broken after 82599 merged.
This results in incorrect reporting, and an erroneous warning message
that the 82598 is in a PCIe slot that isn't fast enough to run 10GbE.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 623737f..ed265a7 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -79,6 +79,9 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 	s32 ret_val = 0;
 	u16 list_offset, data_offset;
 
+	/* Set the bus information prior to PHY identification */
+	mac->ops.get_bus_info(hw);
+
 	/* Call PHY identify routine to get the phy type */
 	ixgbe_identify_phy_generic(hw);
 

