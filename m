From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] igb: fix WOL on second port of i350 device
Date: Thu,  4 Aug 2011 05:18:16 -0700
Message-ID: <1312460298-20405-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14054 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab1HDMSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:40 -0400
In-Reply-To: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where WOL would fail on second port of i350
device.

Reported-by: Martin Wilck <martin.wilck@ts.fujitsu.com>
Reported-by: Stefan Assmann<sassmann@redhat.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ae3937e..40d4c40 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2023,7 +2023,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	if (hw->bus.func == 0)
 		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
-	else if (hw->mac.type == e1000_82580)
+	else if (hw->mac.type >= e1000_82580)
 		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A +
 		                 NVM_82580_LAN_FUNC_OFFSET(hw->bus.func), 1,
 		                 &eeprom_data);
-- 
1.7.6

