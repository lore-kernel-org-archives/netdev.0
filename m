From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] e1000e: update to workaround for jumbo
	frames on 82577
Date: Mon, 02 Aug 2010 17:27:50 -0700
Message-ID: <20100803002748.4179.85660.stgit@localhost.localdomain>
References: <20100803002622.4179.31850.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:50897 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754302Ab0HCA2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 20:28:09 -0400
In-Reply-To: <20100803002622.4179.31850.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

For OEM systems with this part that also has Spread Spectrum Clocking (SSC)
enabled in the BIOS, there is an Rx performance issue with 4K jumbo frames.
Leaving the defaults in PHY page 770 register 26 resolves the issue, and
does not negatively impact jumbo frames on systems with SSC disabled.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 9e9164a..cc97b58 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2727,11 +2727,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	if ((hw->phy.type == e1000_phy_82577) && (rctl & E1000_RCTL_LPE)) {
 		u16 phy_data;
 
-		e1e_rphy(hw, PHY_REG(770, 26), &phy_data);
-		phy_data &= 0xfff8;
-		phy_data |= (1 << 2);
-		e1e_wphy(hw, PHY_REG(770, 26), phy_data);
-
 		e1e_rphy(hw, 22, &phy_data);
 		phy_data &= 0x0fff;
 		phy_data |= (1 << 14);

