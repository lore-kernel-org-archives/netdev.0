From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] ixgbe: fix enum type mismatch on disable
	laser
Date: Fri, 03 Dec 2010 15:24:05 -0800
Message-ID: <20101203232351.21869.98417.stgit@localhost.localdomain>
References: <20101203232218.21869.62349.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:43028
	"EHLO qmta02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754094Ab0LCXY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 18:24:26 -0500
In-Reply-To: <20101203232218.21869.62349.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Fixes a recent bug on the patch (c6ecf39a10ceec3e97096e2a8d3eadcecd593422)
that disabled the laser on ifconfig down.  Compilers were seeing a enum
mismatch.

Signed-off-by Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c5998ca..fdb35d0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3800,7 +3800,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	/* enable the optics for both mult-speed fiber and 82599 SFP+ fiber */
 	if (hw->mac.ops.enable_tx_laser &&
 	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->phy.type == ixgbe_media_type_fiber) &&
+	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
 	      (hw->mac.type == ixgbe_mac_82599EB))))
 		hw->mac.ops.enable_tx_laser(hw);
 
@@ -4122,7 +4122,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
 	if (hw->mac.ops.disable_tx_laser &&
 	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->phy.type == ixgbe_media_type_fiber) &&
+	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
 	      (hw->mac.type == ixgbe_mac_82599EB))))
 		hw->mac.ops.disable_tx_laser(hw);
 
@@ -7215,7 +7215,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
 	if (hw->mac.ops.disable_tx_laser &&
 	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->phy.type == ixgbe_media_type_fiber) &&
+	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
 	      (hw->mac.type == ixgbe_mac_82599EB))))
 		hw->mac.ops.disable_tx_laser(hw);
 

