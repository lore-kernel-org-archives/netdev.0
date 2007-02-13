From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH] fix atl1 braino
Date: Tue, 13 Feb 2007 07:12:56 +0000
Message-ID: <20070213071256.GF4095@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57813 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbXBMHNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 02:13:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spot the bug...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---

diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 08b2d78..e28707a 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -357,7 +357,7 @@ void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
 	 */
 	hash_reg = (hash_value >> 31) & 0x1;
 	hash_bit = (hash_value >> 26) & 0x1F;
-	mta = ioread32((hw + REG_RX_HASH_TABLE) + (hash_reg << 2));
+	mta = ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
 	mta |= (1 << hash_bit);
 	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
 }
