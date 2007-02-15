From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2/6] atl1: fix bad ioread address
Date: Wed, 14 Feb 2007 20:13:39 -0600
Message-ID: <20070215021339.GC9753@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	viro@zeniv.linux.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf16aec.mail.bellsouth.net ([205.152.59.64]:36369 "EHLO
	imf16aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964832AbXBOCNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 21:13:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

An ioread32 statement reads the wrong address.  Fix it.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Signed-off-by: Chris Snook <csnook@redhat.com>
---

 drivers/net/atl1/atl1_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
