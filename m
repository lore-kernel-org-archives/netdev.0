From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/10] tg3: Fix 5717 and 57765 memory selftests
Date: Wed, 20 Jan 2010 18:58:06 -0800
Message-ID: <1264042691-28284-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4728 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753499Ab0AUC6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both the 5717 and the 57765 will fail 'ethtool -t' selftests at the
memory selftest portion.  The memory map for these two devices differs
from the rest of the asic revs and each other.  This patch adds a new
memory map to use for memory selftests.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7a36bf4..44ac9e2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10659,12 +10659,27 @@ static int tg3_test_memory(struct tg3 *tp)
 		{ 0x00008000, 0x01000},
 		{ 0x00010000, 0x01000},
 		{ 0xffffffff, 0x00000}
+	}, mem_tbl_5717[] = {
+		{ 0x00000200, 0x00008},
+		{ 0x00010000, 0x0a000},
+		{ 0x00020000, 0x13c00},
+		{ 0xffffffff, 0x00000}
+	}, mem_tbl_57765[] = {
+		{ 0x00000200, 0x00008},
+		{ 0x00004000, 0x00800},
+		{ 0x00006000, 0x09800},
+		{ 0x00010000, 0x0a000},
+		{ 0xffffffff, 0x00000}
 	};
 	struct mem_entry *mem_tbl;
 	int err = 0;
 	int i;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+		mem_tbl = mem_tbl_5717;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+		mem_tbl = mem_tbl_57765;
+	else if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 		mem_tbl = mem_tbl_5755;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		mem_tbl = mem_tbl_5906;
-- 
1.6.4.4


