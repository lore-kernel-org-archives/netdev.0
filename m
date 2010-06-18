From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] e1000e: do not touch PHY page 800 registers
	when link speed is 1000Mbps
Date: Thu, 17 Jun 2010 21:59:06 -0700
Message-ID: <20100618045904.6728.18894.stgit@localhost.localdomain>
References: <20100618045804.6728.37945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:52254 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752408Ab0FRE7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 00:59:25 -0400
In-Reply-To: <20100618045804.6728.37945.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The PHY on 82577/82578 has issues when the registers on page 800 are
accessed when in gigabit mode.  Do not clear the Wakeup Control register
when resetting the part since it is on page 800 (and will be cleared on
reset anyway).

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 2a71889..aa14976 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3184,8 +3184,6 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		e1000_get_hw_control(adapter);
 
 	ew32(WUC, 0);
-	if (adapter->flags2 & FLAG2_HAS_PHY_WAKEUP)
-		e1e_wphy(&adapter->hw, BM_WUC, 0);
 
 	if (mac->ops.init_hw(hw))
 		e_err("Hardware Error\n");

