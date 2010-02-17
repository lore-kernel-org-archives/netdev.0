From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/18] igb: only support SRRCTL_DROP_EN when
	using multiple queues
Date: Wed, 17 Feb 2010 03:03:38 -0800
Message-ID: <20100217110337.17723.80740.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:33640
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754376Ab0BQLD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:03:56 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

The SRRCTL.DROP_EN bit should only be set when we are supporting
multiple queues. This bit is meant to prevent head of line blocking
and is unnecessary in the single queue case.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4ccc7fc..b989b34 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2595,6 +2595,9 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 		         E1000_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
 	}
+	/* Only set Drop Enable if we are supporting multiple queues */
+	if (adapter->vfs_allocated_count || adapter->num_rx_queues > 1)
+		srrctl |= E1000_SRRCTL_DROP_EN;
 
 	wr32(E1000_SRRCTL(reg_idx), srrctl);
 

