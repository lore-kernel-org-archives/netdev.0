From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: clear mac address data block in DCB mode
Date: Thu, 16 Jul 2009 16:43:10 -0700
Message-ID: <20090716234303.23595.85275.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Lucy Liu <lucy.liu@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:52155
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933620AbZGPXnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 19:43:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucy Liu <lucy.liu@intel.com>

This change clears the address data block memory space, which is needed for
the 82598 which does not have a SAN MAC.

Signed-off-by: Lucy Liu <lucy.liu@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 7c5978a..5b8dab2 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -175,6 +175,8 @@ static void ixgbe_dcbnl_get_perm_hw_addr(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int i, j;
 
+	memset(perm_addr, 0xff, MAX_ADDR_LEN);
+
 	for (i = 0; i < netdev->addr_len; i++)
 		perm_addr[i] = adapter->hw.mac.perm_addr[i];
 

