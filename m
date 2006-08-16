From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/13] e1000: Force full DMA clocking for 10/100 speed
Date: Wed, 16 Aug 2006 14:56:33 -0700
Message-ID: <20060816215633.27080.15056.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:61961 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932257AbWHPVsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:45 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 3728f33..8eddfdf 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -718,6 +718,17 @@ e1000_init_hw(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_init_hw");
 
+    /* force full DMA clock frequency for 10/100 on ICH8 A0-B0 */
+    if (hw->mac_type == e1000_ich8lan) {
+        reg_data = E1000_READ_REG(hw, TARC0);
+        reg_data |= 0x30000000;
+        E1000_WRITE_REG(hw, TARC0, reg_data);
+
+        reg_data = E1000_READ_REG(hw, STATUS);
+        reg_data &= ~0x80000000;
+        E1000_WRITE_REG(hw, STATUS, reg_data);
+    }
+
     /* Initialize Identification LED */
     ret_val = e1000_id_led_init(hw);
     if(ret_val) {



--
Auke Kok <auke-jan.h.kok@intel.com>
