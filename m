From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: disable tx engine before disabling tx laser
Date: Tue, 29 Jun 2010 21:28:36 -0700
Message-ID: <20100630042836.8925.82492.stgit@localhost.localdomain>
References: <20100630042739.8925.24962.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:46795
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751409Ab0F3E3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:29:00 -0400
In-Reply-To: <20100630042739.8925.24962.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Disabling the tx laser while receiving DMA requests
can hang the device.  After this occurs the device
is in a bad state. The GPIO bit never clears when
PCI master access is disabled and a reboot is required
to get the device in a good state again.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e237748..7ddd60e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3684,10 +3684,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
-	/* power down the optics */
-	if (hw->phy.multispeed_fiber)
-		hw->mac.ops.disable_tx_laser(hw);
-
 	/* disable receive for all VFs and wait one second */
 	if (adapter->num_vfs) {
 		/* ping all the active vfs to let them know we are going down */
@@ -3742,6 +3738,10 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		                (IXGBE_READ_REG(hw, IXGBE_DMATXCTL) &
 		                 ~IXGBE_DMATXCTL_TE));
 
+	/* power down the optics */
+	if (hw->phy.multispeed_fiber)
+		hw->mac.ops.disable_tx_laser(hw);
+
 	/* clear n-tuple filters that are cached */
 	ethtool_ntuple_flush(netdev);
 

