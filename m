From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 15/21] e1000: check return value of _get_speed_and_duplex
Date: Wed, 21 Jun 2006 22:20:39 -0700
Message-ID: <20060622052039.25497.41139.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:58888 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932798AbWFVFOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:41 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We were not checking the return value of get_speed_and_duplex
properly, whih may contain an error value.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 37eb351..784f950 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -2737,8 +2737,12 @@ e1000_check_for_link(struct e1000_hw *hw
          */
         if(hw->tbi_compatibility_en) {
             uint16_t speed, duplex;
-            e1000_get_speed_and_duplex(hw, &speed, &duplex);
-            if(speed != SPEED_1000) {
+            ret_val = e1000_get_speed_and_duplex(hw, &speed, &duplex);
+            if (ret_val) {
+                DEBUGOUT("Error getting link speed and duplex\n");
+                return ret_val;
+            }
+            if (speed != SPEED_1000) {
                 /* If link speed is not set to gigabit speed, we do not need
                  * to enable TBI compatibility.
                  */



--
Auke Kok <auke-jan.h.kok@intel.com>
