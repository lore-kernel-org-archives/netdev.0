From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/6] ixgbe: Change the 82599 PHY DSP restart logic
Date: Thu, 04 Jun 2009 14:10:17 -0700
Message-ID: <20090604211016.5011.36503.stgit@localhost.localdomain>
References: <20090604210941.5011.31995.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:47354 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752767AbZFDVKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:10:31 -0400
In-Reply-To: <20090604210941.5011.31995.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

When reprogramming the 82599 analog PHY to either SFI optical or Direct
Attach Twinax, we need to restart the DSP in the PHY.  The current method
can cause contention with our FW which is managing PHY state, and will
cause unexpected link flaps.  This patch fixes the DSP restart by issuing
an AN_RESTART in the MAC, which will properly propagate the DSP restart to
the PHY.  This ensures we don't collide with the FW.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5d27830..a7611bb 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -122,10 +122,9 @@ s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 			IXGBE_WRITE_FLUSH(hw);
 			hw->eeprom.ops.read(hw, ++data_offset, &data_value);
 		}
-		/* Now restart DSP */
-		IXGBE_WRITE_REG(hw, IXGBE_CORECTL, 0x00000102);
-		IXGBE_WRITE_REG(hw, IXGBE_CORECTL, 0x00000b1d);
-		IXGBE_WRITE_FLUSH(hw);
+		/* Now restart DSP by setting Restart_AN */
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC,
+		    (IXGBE_READ_REG(hw, IXGBE_AUTOC) | IXGBE_AUTOC_AN_RESTART));
 
 		/* Release the semaphore */
 		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);

