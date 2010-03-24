From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbe: Change where clear_to_send_flag is reset
	to zero.
Date: Wed, 24 Mar 2010 12:36:27 -0700
Message-ID: <20100324193626.6078.32074.stgit@localhost.localdomain>
References: <20100324193515.6078.27035.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:55517
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932354Ab0CXTgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 15:36:44 -0400
In-Reply-To: <20100324193515.6078.27035.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The clear_to_send flag is being cleared before the call to ping all
the VFs.  It should be called after pinging all the VFs.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2f8c348..315622f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3224,13 +3224,15 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	/* disable receive for all VFs and wait one second */
 	if (adapter->num_vfs) {
-		for (i = 0 ; i < adapter->num_vfs; i++)
-			adapter->vfinfo[i].clear_to_send = 0;
-
 		/* ping all the active vfs to let them know we are going down */
 		ixgbe_ping_all_vfs(adapter);
+
 		/* Disable all VFTE/VFRE TX/RX */
 		ixgbe_disable_tx_rx(adapter);
+
+		/* Mark all the VFs as inactive */
+		for (i = 0 ; i < adapter->num_vfs; i++)
+			adapter->vfinfo[i].clear_to_send = 0;
 	}
 
 	/* disable receives */

