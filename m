From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 03/11] ixgbe: Disable DROP_EN for Rx queues
Date: Sat, 14 Mar 2009 01:13:08 -0700
Message-ID: <20090314081308.4687.4574.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:41439
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754038AbZCNIN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:13:29 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

82599 mistakenly enabled drop on Rx queues in the packet buffer.  The
default mode should be store-and-forward from the FIFO.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c18d0f3..320da14 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1679,8 +1679,6 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 			srrctl |= rx_ring->rx_buf_len >>
 			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 	}
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-		srrctl |= IXGBE_SRRCTL_DROP_EN;
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }

