From: Alexander Sverdlin <asv@sysgo.com>
Subject: [PATCH] phy: Replace genphy_update_link() call with phy_read_status()
Date: Thu, 13 Sep 2012 09:20:43 +0200
Message-ID: <5051894B.5060001@sysgo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sysgo.com ([176.9.26.183]:40843 "EHLO mail1.sysgo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab2IMHUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 03:20:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <alexander.sverdlin@sysgo.com>

Replace genphy_update_link() call with phy_read_status() 

Code in phy.c should not call genphy_*() functions directly, this breaks PHY layer abstraction.
Some drivers may re-implement "read_status" callback and it's not being called in one place of
PHY state machine, where genphy_update_link() is called instead. So fix it.
For drivers that rely on genphy_* implementation nothing changed, as genphy_read_status() calls
genphy_update_link() anyway.

Signed-off-by: Alexander Sverdlin <alexander.sverdlin@sysgo.com>
---
 drivers/net/phy/phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index dfca51d..cfed41c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -839,7 +839,7 @@ void phy_state_machine(struct work_struct *work)
 			}
 			break;
 		case PHY_FORCING:
-			err = genphy_update_link(phydev);
+			err = phy_read_status(phydev);
 
 			if (err)
 				break;
