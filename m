From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 3/9] igb: Add check for invalid size to igb_get_invariants_82575()
Date: Wed,  4 May 2011 12:30:35 -0700
Message-ID: <1304537441-2056-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755415Ab1EDTaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:46 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Recent commits have changed how EEPROM size is checked and if the size
word is misconfigured, the driver will fail to load.  This patch adds a
check for invalid size word in the EEPROM and uses default size instead
for 82576 parts.

Reported-by: Stefan Assmann <sassmann@redhat.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_82575.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 0cd41c4..0f563c8 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -244,6 +244,14 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
 
+	/*
+	 * Check for invalid size
+	 */
+	if ((hw->mac.type == e1000_82576) && (size > 15)) {
+		printk("igb: The NVM size is not valid, "
+			"defaulting to 32K.\n");
+		size = 15;
+	}
 	nvm->word_size = 1 << size;
 	if (nvm->word_size == (1 << 15))
 		nvm->page_size = 128;
-- 
1.7.4.4

