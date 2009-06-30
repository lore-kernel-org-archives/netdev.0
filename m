From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/4] ixgbe: Fix link capabilities during adapter resets
Date: Tue, 30 Jun 2009 14:44:36 -0700
Message-ID: <20090630214436.17464.65010.stgit@localhost.localdomain>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:51671 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753193AbZF3Vow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 17:44:52 -0400
In-Reply-To: <20090630214349.17464.25370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Adapter link advertisement capabilities were not persistent during
adapter resets. While configuring multispeed fiber link check for
phy autoneg_advertised settings before overwriting with default
link capabilities

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 30d8c0e..fce2ef4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4506,7 +4506,8 @@ static void ixgbe_multispeed_fiber_task(struct work_struct *work)
 	u32 autoneg;
 
 	adapter->flags |= IXGBE_FLAG_IN_SFP_LINK_TASK;
-	if (hw->mac.ops.get_link_capabilities)
+	autoneg = hw->phy.autoneg_advertised;
+	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
 		hw->mac.ops.get_link_capabilities(hw, &autoneg,
 		                                  &hw->mac.autoneg);
 	if (hw->mac.ops.setup_link_speed)

