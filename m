From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] e1000: clean up the checking logic
Date: Sun, 13 Dec 2015 00:31:20 -0800
Message-ID: <1449995490-17020-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Mark Rustad <mark.d.rustad@intel.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:34868 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbbLMIk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:40:58 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The checking logic needed some clean-up work, so we rewrite it by
checking for break first. With that change in place, we can even move
the second check for goto statement outside of the loop.

As this is merely a cleanup, no functional change is involved. The
questionable 'tmp != 0xFF' is intentionally left alone.

Mark Rustad and Alexander Duyck contributed to this patch.

CC: Mark Rustad <mark.d.rustad@intel.com>
CC: Alex Duyck <aduyck@mirantis.com>
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 12d59a4..a0f3a31 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1199,13 +1199,13 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		for (i = 0; i < 32; i++) {
 			hw->phy_addr = i;
 			e1000_read_phy_reg(hw, PHY_ID2, &tmp);
-			if (tmp == 0 || tmp == 0xFF) {
-				if (i == 31)
-					goto err_eeprom;
-				continue;
-			} else
+
+			if (tmp != 0 && tmp != 0xFF)
 				break;
 		}
+
+		if (i >= 32)
+			goto err_eeprom;
 	}
 
 	/* reset the hardware with the new settings */
-- 
2.5.0
