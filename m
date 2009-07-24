From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/13] igb: initialize mailbox function pointers
	prior to phy init
Date: Thu, 23 Jul 2009 21:10:43 -0700
Message-ID: <20090724041042.30709.72711.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:48723
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838AbZGXEK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:10:59 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver is currently initializing the mailbox function pointers
after the phy.  This causes issues as the phy init will return from the
function early if there is no phy present.

To resolve this I have moved the function pointer init to a location prior
to the phy initialization so that serdes based adapters can also make use
of SR-IOV.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index dbbd72f..6158c0f 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -172,6 +172,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		size = 14;
 	nvm->word_size = 1 << size;
 
+	/* if 82576 then initialize mailbox parameters */
+	if (mac->type == e1000_82576)
+		igb_init_mbx_params_pf(hw);
+
 	/* setup PHY parameters */
 	if (phy->media_type != e1000_media_type_copper) {
 		phy->type = e1000_phy_none;
@@ -221,10 +225,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		return -E1000_ERR_PHY;
 	}
 
-	/* if 82576 then initialize mailbox parameters */
-	if (mac->type == e1000_82576)
-		igb_init_mbx_params_pf(hw);
-
 	return 0;
 }
 

