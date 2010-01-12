From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/5] tg3: Disable 5717 serdes and B0 support
Date: Tue, 12 Jan 2010 12:11:39 -0800
Message-ID: <1263327100-13554-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1099 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754191Ab0ALUMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 15:12:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The B0 revision of the 5717 will not get enough testing by the time
2.6.33 ships.  Since the kernel is already at RC3, serdes support
will require too many patches to fix.  For these reasons, this patch
disables 5717 serdes support and will refuse to attach to all 5717
devices that are later than an A0 revision.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0a632f9..2d1a740 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13390,6 +13390,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (err)
 		return err;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	    (tp->pci_chip_rev_id != CHIPREV_ID_5717_A0 ||
+		 (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)))
+		return -ENOTSUPP;
+
 	/* Initialize data/descriptor byte/word swapping. */
 	val = tr32(GRC_MODE);
 	val &= GRC_MODE_HOST_STACKUP;
-- 
1.6.4.4


