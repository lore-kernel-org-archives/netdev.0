From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 07/13] e1000: Allow NVM to setup LPLU for IGP2 and IGP3
Date: Wed, 16 Aug 2006 14:56:31 -0700
Message-ID: <20060816215630.27080.11706.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:60681 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932258AbWHPVsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:42 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Allow NVM to setup LPLU for IGP2 and IGP3. Only IGP needs LPLU D3
disabled during init here.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 583518a..3728f33 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -1324,11 +1324,14 @@ e1000_copper_link_igp_setup(struct e1000
     E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
     }
 
-    /* disable lplu d3 during driver init */
-    ret_val = e1000_set_d3_lplu_state(hw, FALSE);
-    if (ret_val) {
-        DEBUGOUT("Error Disabling LPLU D3\n");
-        return ret_val;
+    /* The NVM settings will configure LPLU in D3 for IGP2 and IGP3 PHYs */
+    if (hw->phy_type == e1000_phy_igp) {
+        /* disable lplu d3 during driver init */
+        ret_val = e1000_set_d3_lplu_state(hw, FALSE);
+        if (ret_val) {
+            DEBUGOUT("Error Disabling LPLU D3\n");
+            return ret_val;
+        }
     }
 
     /* disable lplu d0 during driver init */



--
Auke Kok <auke-jan.h.kok@intel.com>
