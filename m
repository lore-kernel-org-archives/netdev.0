From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/26] e1000: remove unused part_num reading code
Date: Tue, 29 Aug 2006 09:44:27 -0700
Message-ID: <20060829164427.6872.34395.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:32010 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965079AbWH2QgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:14 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove the code that reads part_num from the EEPROM. This part number
is never displayed or queryable by the user.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_hw.c   |   34 ----------------------------------
 drivers/net/e1000/e1000_main.c |    2 --
 3 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index c110781..70ba378 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -245,7 +245,6 @@ struct e1000_adapter {
 	uint16_t mng_vlan_id;
 	uint32_t bd_number;
 	uint32_t rx_buffer_len;
-	uint32_t part_num;
 	uint32_t wol;
 	uint32_t ksp3_port_a;
 	uint32_t smartspeed;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 57749eb..f56d4cd 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -5556,40 +5556,6 @@ e1000_commit_shadow_ram(struct e1000_hw 
 }
 
 /******************************************************************************
- * Reads the adapter's part number from the EEPROM
- *
- * hw - Struct containing variables accessed by shared code
- * part_num - Adapter's part number
- *****************************************************************************/
-int32_t
-e1000_read_part_num(struct e1000_hw *hw,
-                    uint32_t *part_num)
-{
-    uint16_t offset = EEPROM_PBA_BYTE_1;
-    uint16_t eeprom_data;
-
-    DEBUGFUNC("e1000_read_part_num");
-
-    /* Get word 0 from EEPROM */
-    if (e1000_read_eeprom(hw, offset, 1, &eeprom_data) < 0) {
-        DEBUGOUT("EEPROM Read Error\n");
-        return -E1000_ERR_EEPROM;
-    }
-    /* Save word 0 in upper half of part_num */
-    *part_num = (uint32_t) (eeprom_data << 16);
-
-    /* Get word 1 from EEPROM */
-    if (e1000_read_eeprom(hw, ++offset, 1, &eeprom_data) < 0) {
-        DEBUGOUT("EEPROM Read Error\n");
-        return -E1000_ERR_EEPROM;
-    }
-    /* Save word 1 in lower half of part_num */
-    *part_num |= eeprom_data;
-
-    return E1000_SUCCESS;
-}
-
-/******************************************************************************
  * Reads the adapter's MAC address from the EEPROM and inverts the LSB for the
  * second function of dual function devices
  *
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 630fe60..c128f62 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -853,8 +853,6 @@ e1000_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	e1000_read_part_num(&adapter->hw, &(adapter->part_num));
-
 	e1000_get_bus_info(&adapter->hw);
 
 	init_timer(&adapter->tx_fifo_stall_timer);



---
Auke Kok <auke-jan.h.kok@intel.com>
