From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/4] igb: do not force retry count to 1 on 82580 phy
Date: Wed, 23 Dec 2009 15:21:07 -0800
Message-ID: <20091223232107.16146.15573.stgit@localhost.localdomain>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:35064
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753422AbZLWXV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:21:26 -0500
In-Reply-To: <20091223232047.16146.35264.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change resolves an issue seen in some configurations where the link
may drop to 100Mb/s even though the link itself supports 1000Mb/s.  The
issue was root caused to the fact that we were only trying the link once.
Now instead we will try up to 5 attempts on a faulty cable before
downshifting to 100Mb/s.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_phy.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index 5c9d73e..3670a66 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -457,15 +457,6 @@ s32 igb_copper_link_setup_82580(struct e1000_hw *hw)
 	phy_data |= I82580_CFG_ENABLE_DOWNSHIFT;
 
 	ret_val = phy->ops.write_reg(hw, I82580_CFG_REG, phy_data);
-	if (ret_val)
-		goto out;
-
-	/* Set number of link attempts before downshift */
-	ret_val = phy->ops.read_reg(hw, I82580_CTRL_REG, &phy_data);
-	if (ret_val)
-		goto out;
-	phy_data &= ~I82580_CTRL_DOWNSHIFT_MASK;
-	ret_val = phy->ops.write_reg(hw, I82580_CTRL_REG, phy_data);
 
 out:
 	return ret_val;

