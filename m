From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] stmmac: remove custom implementation of print_hex_dump()
Date: Mon,  3 Nov 2014 19:28:54 +0200
Message-ID: <1415035734-24163-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38380 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908AbaKCR25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 12:28:57 -0500
In-Reply-To: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a kernel helper to dump buffers in a hexdecimal format. This patch
substitutes the open coded function by calling that helper.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6f77a46..5fb87f5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -191,14 +191,8 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 
 static void print_pkt(unsigned char *buf, int len)
 {
-	int j;
-	pr_debug("len = %d byte, buf addr: 0x%p", len, buf);
-	for (j = 0; j < len; j++) {
-		if ((j % 16) == 0)
-			pr_debug("\n %03x:", j);
-		pr_debug(" %02x", buf[j]);
-	}
-	pr_debug("\n");
+	pr_debug("len = %d byte, buf addr: 0x%p\n", len, buf);
+	print_hex_dump(KERN_DEBUG, " ", DUMP_PREFIX_OFFSET, 16, 1, buf, len, 0);
 }
 
 /* minimum number of free TX descriptors required to wake up TX process */
-- 
2.1.1
