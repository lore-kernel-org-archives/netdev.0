From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] e1000: Fix driver to be used on PA RISC C8000 workstations
Date: Tue, 30 Aug 2011 17:19:26 -0700
Message-ID: <1314749966-9960-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, stable@kernel.org,
	Guy Martin <gmsoft@tuxicoman.be>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Matt Turner <mattst88@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62279 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120Ab1HaATa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 20:19:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The checksum field in the EEPROM on HPPA is really not a
checksum but a signature (0x16d6).  So allow 0x16d6 as the
matching checksum on HPPA systems.

This issue is present on longterm/stable kernels, I have
verified that this patch is applicable back to at least
2.6.32.y kernels.

CC: Guy Martin <gmsoft@tuxicoman.be>
CC: Rolf Eike Beer <eike-kernel@sf-tec.de>
CC: Matt Turner <mattst88@gmail.com>
Reported-by: Mikulas Patocka <mikulas@artax.kerlin.mff.cuni.cz>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 drivers/net/e1000/e1000_hw.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 8545c7a..08c1ad5 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -4026,6 +4026,12 @@ s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 		checksum += eeprom_data;
 	}
 
+#ifdef __hppa__
+	/* This is a signature and not a checksum on HP c8000 */
+	if ((hw->subsystem_vendor_id == 0x103C) && (eeprom_data == 0x16d6))
+		return E1000_SUCCESS;
+
+#endif
 	if (checksum == (u16) EEPROM_SUM)
 		return E1000_SUCCESS;
 	else {
-- 
1.7.6
