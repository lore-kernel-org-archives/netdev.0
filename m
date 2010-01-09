From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/13] ixgbe: Fix ethtool diag test for VT mode
	operation
Date: Sat, 09 Jan 2010 04:27:05 -0800
Message-ID: <20100109122704.4462.60493.stgit@localhost.localdomain>
References: <20100109120719.4462.66489.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:33196 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753949Ab0AIM1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:27:22 -0500
In-Reply-To: <20100109120719.4462.66489.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Skip MAC loopback test when the adapter is set to a VT mode such as SR-IOV
or VMDq

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 0bd49d3..a0107b5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1867,11 +1867,22 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		if (ixgbe_intr_test(adapter, &data[2]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
+		/* If SRIOV or VMDq is enabled then skip MAC
+		 * loopback diagnostic. */
+		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
+				      IXGBE_FLAG_VMDQ_ENABLED)) {
+			DPRINTK(HW, INFO, "Skip MAC loopback diagnostic in VT "
+				"mode\n");
+			data[3] = 0;
+			goto skip_loopback;
+		}
+
 		ixgbe_reset(adapter);
 		DPRINTK(HW, INFO, "loopback testing starting\n");
 		if (ixgbe_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
+skip_loopback:
 		ixgbe_reset(adapter);
 
 		clear_bit(__IXGBE_TESTING, &adapter->state);

