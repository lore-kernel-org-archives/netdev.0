From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: modify register test for i350 to reflect
	read only bits in RDLEN/TDLEN
Date: Fri, 09 Apr 2010 12:53:08 -0700
Message-ID: <20100409195306.30654.19260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:39517
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755376Ab0DITx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 15:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The registers for RDLEN/TDLEN on i350 have the first 7 bits as read only.
This is a change from previous hardware in which it was only the first 4
bits that were read only.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index cdebfbf..be0678a 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -909,10 +909,10 @@ static struct igb_reg_test reg_test_i350[] = {
 	{ E1000_VET,	   0x100, 1,  PATTERN_TEST, 0xFFFF0000, 0xFFFF0000 },
 	{ E1000_RDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
 	{ E1000_RDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	{ E1000_RDBAL(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
 	{ E1000_RDBAH(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDLEN(4),  0x40,  4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RDLEN(4),  0x40,  4,  PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	/* RDH is read-only for i350, only test RDT. */
 	{ E1000_RDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_RDT(4),	   0x40,  4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
@@ -921,10 +921,10 @@ static struct igb_reg_test reg_test_i350[] = {
 	{ E1000_TIPG,	   0x100, 1,  PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
 	{ E1000_TDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
 	{ E1000_TDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_TDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	{ E1000_TDBAL(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
 	{ E1000_TDBAH(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_TDLEN(4),  0x40,  4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDLEN(4),  0x40,  4,  PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	{ E1000_TDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_TDT(4),	   0x40,  4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_RCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },

