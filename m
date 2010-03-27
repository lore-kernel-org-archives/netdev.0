From: Joe Perches <joe@perches.com>
Subject: [PATCH] e1000e: typo corrections
Date: Fri, 26 Mar 2010 23:16:59 -0700
Message-ID: <1269670619.1603.9.camel@Joe-Laptop.home>
References: <20100324225529.7104.17189.stgit@localhost.localdomain>
	 <20100326.210555.251082007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1162 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529Ab0C0GRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Mar 2010 02:17:04 -0400
In-Reply-To: <20100326.210555.251082007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are the other miscellaneous corrections
done by an earlier larger suggested patch now
made unnecessary by a less invasive change.

Correct a few missing newlines from logging
messages and a typo fix.  Fix speed/duplex
logging message.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000e/82571.c   |    2 +-
 drivers/net/e1000e/ich8lan.c |    6 +++---
 drivers/net/e1000e/lib.c     |   21 +++++++++------------
 3 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 712ccc6..4b0016d 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -323,7 +323,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	}
 
 	/*
-	 * Initialze device specific counter of SMBI acquisition
+	 * Initialize device specific counter of SMBI acquisition
 	 * timeouts.
 	 */
 	 hw->dev_spec.e82571.smb_counter = 0;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8b5e157..5059c22 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1622,7 +1622,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	/* Check if the flash descriptor is valid */
 	if (hsfsts.hsf_status.fldesvalid == 0) {
 		e_dbg("Flash descriptor invalid.  "
-			 "SW Sequencing must be used.");
+			 "SW Sequencing must be used.\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -1671,7 +1671,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 			hsfsts.hsf_status.flcdone = 1;
 			ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		} else {
-			e_dbg("Flash controller busy, cannot get access");
+			e_dbg("Flash controller busy, cannot get access\n");
 		}
 	}
 
@@ -1822,7 +1822,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 				continue;
 			} else if (hsfsts.hsf_status.flcdone == 0) {
 				e_dbg("Timeout error - flash cycle "
-					 "did not complete.");
+					 "did not complete.\n");
 				break;
 			}
 		}
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index a8b2c0d..b0d2a60 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1262,24 +1262,21 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dup
 	u32 status;
 
 	status = er32(STATUS);
-	if (status & E1000_STATUS_SPEED_1000) {
+	if (status & E1000_STATUS_SPEED_1000)
 		*speed = SPEED_1000;
-		e_dbg("1000 Mbs, ");
-	} else if (status & E1000_STATUS_SPEED_100) {
+	else if (status & E1000_STATUS_SPEED_100)
 		*speed = SPEED_100;
-		e_dbg("100 Mbs, ");
-	} else {
+	else
 		*speed = SPEED_10;
-		e_dbg("10 Mbs, ");
-	}
 
-	if (status & E1000_STATUS_FD) {
+	if (status & E1000_STATUS_FD)
 		*duplex = FULL_DUPLEX;
-		e_dbg("Full Duplex\n");
-	} else {
+	else
 		*duplex = HALF_DUPLEX;
-		e_dbg("Half Duplex\n");
-	}
+
+	e_dbg("%u Mbps, %s Duplex\n",
+	      *speed == SPEED_1000 ? 1000 : *speed == SPEED_100 ? 100 : 10,
+	      *duplex == FULL_DUPLEX ? "Full" : "Half");
 
 	return 0;
 }


