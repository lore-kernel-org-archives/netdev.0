From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] stmmac: remove custom implementation of print_hex_dump()
Date: Fri,  7 Nov 2014 16:53:12 +0200
Message-ID: <1415371992-12915-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Joe Perches <joe@perches.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2228 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbaKGOxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 09:53:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a kernel helper to dump buffers in a hexdecimal format. This patch
substitutes the open coded function by calling that helper.

The output is slightly changed:
 - no lead space
 - ASCII part will be printed along with the dump
 - offset is longer than 3 characters (now 8)

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
Since v1:
- address Joe's comments
- describe output change
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index fa598b9..53db11b 100644
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
+	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buf, len);
 }
 
 /* minimum number of free TX descriptors required to wake up TX process */
-- 
2.1.3
