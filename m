From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/7] e1000e: 82573 can use eerd method to read eeprom
Date: Thu, 21 Feb 2008 15:10:47 -0800
Message-ID: <20080221231047.5595.29029.stgit@localhost.localdomain>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11050 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758923AbYBUXVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 18:21:42 -0500
In-Reply-To: <20080221231041.5595.4933.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies the 82571/2/3 family initialization a bit
and removes an initialization table no longer needed.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 3beace5..f7ffd35 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1281,16 +1281,6 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 
 static struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_82571,
-	.read_nvm		= e1000e_read_nvm_spi,
-	.release_nvm		= e1000_release_nvm_82571,
-	.update_nvm		= e1000_update_nvm_checksum_82571,
-	.valid_led_default	= e1000_valid_led_default_82571,
-	.validate_nvm		= e1000_validate_nvm_checksum_82571,
-	.write_nvm		= e1000_write_nvm_82571,
-};
-
-static struct e1000_nvm_operations e82573_nvm_ops = {
-	.acquire_nvm		= e1000_acquire_nvm_82571,
 	.read_nvm		= e1000e_read_nvm_eerd,
 	.release_nvm		= e1000_release_nvm_82571,
 	.update_nvm		= e1000_update_nvm_checksum_82571,
@@ -1355,6 +1345,6 @@ struct e1000_info e1000_82573_info = {
 	.get_invariants		= e1000_get_invariants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_m88,
-	.nvm_ops		= &e82573_nvm_ops,
+	.nvm_ops		= &e82571_nvm_ops,
 };
 

