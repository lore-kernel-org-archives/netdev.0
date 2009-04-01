From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/5] igb: cleanup igb loopback path
Date: Tue, 31 Mar 2009 23:38:56 -0700
Message-ID: <20090401063856.3046.80012.stgit@lost.foo-projects.org>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:57692
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757102AbZDAGjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:39:16 -0400
In-Reply-To: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The code path for setting up phy loopback testing was out of date and was
setting bits it didn't need to.  This change cleans up the code path and
removes some code that has no effect on teh driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index fb09c8a..27eae49 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1419,7 +1419,6 @@ static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_reg = 0;
-	u32 stat_reg = 0;
 
 	hw->mac.autoneg = false;
 
@@ -1443,18 +1442,11 @@ static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
 	ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
 		     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
 		     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
-		     E1000_CTRL_FD);	 /* Force Duplex to FULL */
+		     E1000_CTRL_FD |	 /* Force Duplex to FULL */
+		     E1000_CTRL_SLU);	 /* Set link up enable bit */
 
-	if (hw->phy.media_type == e1000_media_type_copper &&
-	    hw->phy.type == e1000_phy_m88)
+	if (hw->phy.type == e1000_phy_m88)
 		ctrl_reg |= E1000_CTRL_ILOS; /* Invert Loss of Signal */
-	else {
-		/* Set the ILOS bit on the fiber Nic if half duplex link is
-		 * detected. */
-		stat_reg = rd32(E1000_STATUS);
-		if ((stat_reg & E1000_STATUS_FD) == 0)
-			ctrl_reg |= (E1000_CTRL_ILOS | E1000_CTRL_SLU);
-	}
 
 	wr32(E1000_CTRL, ctrl_reg);
 

