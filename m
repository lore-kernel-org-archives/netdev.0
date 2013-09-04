From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  1/9] igb: Don't look for a PBA in the iNVM when flashless
Date: Wed,  4 Sep 2013 06:08:48 -0700
Message-ID: <1378300136-26003-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17747 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757355Ab3IDNI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:08:59 -0400
In-Reply-To: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

When a part is flashless, do not look for a PBA in the iNVM.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index df33c4b..78f49cf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2367,7 +2367,14 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			  "Width x1" : "unknown"), netdev->dev_addr);
 	}
 
-	ret_val = igb_read_part_string(hw, part_str, E1000_PBANUM_LENGTH);
+	if ((hw->mac.type >= e1000_i210 ||
+	     igb_get_flash_presence_i210(hw))) {
+		ret_val = igb_read_part_string(hw, part_str,
+					       E1000_PBANUM_LENGTH);
+	} else {
+		ret_val = -E1000_ERR_INVM_VALUE_NOT_FOUND;
+	}
+
 	if (ret_val)
 		strcpy(part_str, "Unknown");
 	dev_info(&pdev->dev, "%s: PBA No: %s\n", netdev->name, part_str);
-- 
1.8.3.1
