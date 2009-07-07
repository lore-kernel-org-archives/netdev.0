From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb: set lan id prior to configuring phy
Date: Tue, 07 Jul 2009 16:01:55 -0700
Message-ID: <20090707230149.20967.85805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:41640 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755336AbZGGXCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 19:02:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver was defaulting to using the lock for pci-e function 0 for
all of the phys due to the fact that the lan id was not being set prior to
initialization.  This change makes it so that the function id is set prior
to checking for the phy id.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index efd9be2..ac28dd5 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -190,6 +190,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		phy->ops.write_reg          = igb_write_phy_reg_igp;
 	}
 
+	/* set lan id */
+	hw->bus.func = (rd32(E1000_STATUS) & E1000_STATUS_FUNC_MASK) >>
+	               E1000_STATUS_FUNC_SHIFT;
+
 	/* Set phy->phy_addr and phy->id. */
 	ret_val = igb_get_phy_id_82575(hw);
 	if (ret_val)

