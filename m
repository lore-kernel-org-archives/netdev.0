From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: [PATCH] atl1e: remove unnecessary crc inversion
Date: Tue, 11 Nov 2008 16:21:48 -0600
Message-ID: <20081111162148.5b56db58@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, David Madore <david.madore@ens.fr>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:48213 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbYKKWVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 17:21:54 -0500
Received: by rv-out-0506.google.com with SMTP id k40so104486rvb.1
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 14:21:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

atl1e: remove unnecessary crc inversion

Inverting the crc after calling ether_crc_le() is unnecessary and breaks
multicast. Remove it.

Tested-by: David Madore <david.madore@ens.fr>
Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
Cc: stable@kernel.org
---
 drivers/net/atl1e/atl1e_hw.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 949e753..c0d5f7c 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -163,9 +163,6 @@ int atl1e_read_mac_addr(struct atl1e_hw *hw)
  * atl1e_hash_mc_addr
  *  purpose
  *      set hash value for a multicast address
- *      hash calcu processing :
- *          1. calcu 32bit CRC for multicast address
- *          2. reverse crc with MSB to LSB
  */
 u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
 {
@@ -174,7 +171,6 @@ u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
 	int i;
 
 	crc32 = ether_crc_le(6, mc_addr);
-	crc32 = ~crc32;
 	for (i = 0; i < 32; i++)
 		value |= (((crc32 >> i) & 1) << (31 - i));
 
-- 
1.5.6.5
