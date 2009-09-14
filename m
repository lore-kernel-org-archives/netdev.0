From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] igb: do not allow phy sw reset code to make
	calls to null pointers
Date: Mon, 14 Sep 2009 11:23:13 -0700
Message-ID: <20090914182312.4859.21938.stgit@localhost.localdomain>
References: <20090914182253.4859.11176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:37309
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932913AbZINSX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 14:23:26 -0400
In-Reply-To: <20090914182253.4859.11176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In the case of fiber and serdes adapters we were seeing issues with ethtool
-t causing kernel panics due to null function pointers.  To prevent this we
need to exit out of the phy reset code in the event that we do not have a
valid phy.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/igb/e1000_phy.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index c1f4da6..ee46060 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -1565,9 +1565,12 @@ out:
  **/
 s32 igb_phy_sw_reset(struct e1000_hw *hw)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 phy_ctrl;
 
+	if (!(hw->phy.ops.read_reg))
+		goto out;
+
 	ret_val = hw->phy.ops.read_reg(hw, PHY_CONTROL, &phy_ctrl);
 	if (ret_val)
 		goto out;

