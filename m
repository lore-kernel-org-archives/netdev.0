From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] e1000e: remove unnecessary check for NULL pointer
Date: Thu,  4 Aug 2011 05:18:14 -0700
Message-ID: <1312460298-20405-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1910 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297Ab1HDMSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:38 -0400
In-Reply-To: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The array shadow_ram is never NULL.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index f7a75c1..4e36978 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2137,8 +2137,7 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	ret_val = 0;
 	for (i = 0; i < words; i++) {
-		if ((dev_spec->shadow_ram) &&
-		    (dev_spec->shadow_ram[offset+i].modified)) {
+		if (dev_spec->shadow_ram[offset+i].modified) {
 			data[i] = dev_spec->shadow_ram[offset+i].value;
 		} else {
 			ret_val = e1000_read_flash_word_ich8lan(hw,
-- 
1.7.6

