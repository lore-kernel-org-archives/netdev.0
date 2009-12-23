From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/4] igb: do not force pcs link when in KX mode
Date: Wed, 23 Dec 2009 15:20:47 -0800
Message-ID: <20091223232047.16146.35264.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:43239
	"EHLO QMTA14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752155AbZLWXVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:21:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We were forcing the PCS link up in error when we are in KX mode.  We should
only be disabling autoneg, not forcing the link up.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index e8e9e91..c505b50 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1096,9 +1096,7 @@ static s32 igb_setup_serdes_link_82575(struct e1000_hw *hw)
 		hw_dbg("Configuring Autoneg:PCS_LCTL=0x%08X\n", reg);
 	} else {
 		/* Set PCS register for forced link */
-		reg |= E1000_PCS_LCTL_FSD |        /* Force Speed */
-		       E1000_PCS_LCTL_FORCE_LINK | /* Force Link */
-		       E1000_PCS_LCTL_FLV_LINK_UP; /* Force link value up */
+		reg |= E1000_PCS_LCTL_FSD;        /* Force Speed */
 
 		hw_dbg("Configuring Forced Link:PCS_LCTL=0x%08X\n", reg);
 	}

