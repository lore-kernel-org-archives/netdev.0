From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 6/6] e1000e: remove unnecessary 82577 workaround
	causing link issues
Date: Thu, 19 Nov 2009 14:36:04 -0800
Message-ID: <20091119223604.29164.11087.stgit@localhost.localdomain>
References: <20091119223406.29164.22513.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:60579
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757264AbZKSWgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:36:16 -0500
In-Reply-To: <20091119223406.29164.22513.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A workaround for pre-release versions of 82577 is causing link issues on
some switches.  The workaround is no longer needed on production parts so
remove it.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/phy.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 8189d00..85f955f 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -71,7 +71,6 @@ static const u16 e1000_igp_2_cable_length_table[] =
 #define I82577_CFG_ASSERT_CRS_ON_TX       (1 << 15)
 #define I82577_CFG_ENABLE_DOWNSHIFT       (3 << 10) /* auto downshift 100/10 */
 #define I82577_CTRL_REG                   23
-#define I82577_CTRL_DOWNSHIFT_MASK        (7 << 10)
 
 /* 82577 specific PHY registers */
 #define I82577_PHY_CTRL_2            18
@@ -660,15 +659,6 @@ s32 e1000_copper_link_setup_82577(struct e1000_hw *hw)
 	phy_data |= I82577_CFG_ENABLE_DOWNSHIFT;
 
 	ret_val = phy->ops.write_phy_reg(hw, I82577_CFG_REG, phy_data);
-	if (ret_val)
-		goto out;
-
-	/* Set number of link attempts before downshift */
-	ret_val = phy->ops.read_phy_reg(hw, I82577_CTRL_REG, &phy_data);
-	if (ret_val)
-		goto out;
-	phy_data &= ~I82577_CTRL_DOWNSHIFT_MASK;
-	ret_val = phy->ops.write_phy_reg(hw, I82577_CTRL_REG, phy_data);
 
 out:
 	return ret_val;

