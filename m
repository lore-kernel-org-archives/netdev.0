From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 01/18] igb: limit EEPROM access
Date: Fri, 27 Jun 2008 10:59:33 -0700
Message-ID: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63388 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755284AbYF0R7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 13:59:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEPROM access beyond the base eeprom page is unsupported.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/e1000_82575.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index cda3ec8..39d44dc 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -171,6 +171,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	 * for setting word_size.
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
+
+	/* EEPROM access above 16k is unsupported */
+	if (size > 14)
+		size = 14;
 	nvm->word_size = 1 << size;
 
 	/* setup PHY parameters */

