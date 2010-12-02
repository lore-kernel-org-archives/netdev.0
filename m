From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix possible NULL pointer deference in
	shutdown path
Date: Wed, 01 Dec 2010 22:54:53 -0800
Message-ID: <20101202065447.13252.88901.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:38723 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753581Ab0LBGzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 01:55:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

After freeing the rings we were not zeroing out the ring count values.
This patch now clears these counts correctly.

Reported-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 0 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fbad4d8..eee0b29 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4771,6 +4771,9 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i] = NULL;
 	}
 
+	adapter->num_tx_queues = 0;
+	adapter->num_rx_queues = 0;
+
 	ixgbe_free_q_vectors(adapter);
 	ixgbe_reset_interrupt_capability(adapter);
 }

