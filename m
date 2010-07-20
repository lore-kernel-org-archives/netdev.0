From: akpm@linux-foundation.org
Subject: [patch 1/3] drivers/net/cxgb3/t3_hw.c: use new hex_to_bin() method
Date: Tue, 20 Jul 2010 15:25:16 -0700
Message-ID: <201007202225.o6KMPGnA021443@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ext-andriy.shevchenko@nokia.com, divy@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53195 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932831Ab0GTWZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 18:25:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>

Get rid of own implementation of hex_to_bin().

Signed-off-by: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>
Acked-by: Divy Le Ray <divy@chelsio.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/cxgb3/t3_hw.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff -puN drivers/net/cxgb3/t3_hw.c~drivers-net-cxgb3-t3_hwc-use-new-hex_to_bin-method drivers/net/cxgb3/t3_hw.c
--- a/drivers/net/cxgb3/t3_hw.c~drivers-net-cxgb3-t3_hwc-use-new-hex_to_bin-method
+++ a/drivers/net/cxgb3/t3_hw.c
@@ -679,14 +679,6 @@ int t3_seeprom_wp(struct adapter *adapte
 	return t3_seeprom_write(adapter, EEPROM_STAT_ADDR, enable ? 0xc : 0);
 }
 
-/*
- * Convert a character holding a hex digit to a number.
- */
-static unsigned int hex2int(unsigned char c)
-{
-	return isdigit(c) ? c - '0' : toupper(c) - 'A' + 10;
-}
-
 /**
  *	get_vpd_params - read VPD parameters from VPD EEPROM
  *	@adapter: adapter to read
@@ -727,15 +719,15 @@ static int get_vpd_params(struct adapter
 		p->port_type[0] = uses_xaui(adapter) ? 1 : 2;
 		p->port_type[1] = uses_xaui(adapter) ? 6 : 2;
 	} else {
-		p->port_type[0] = hex2int(vpd.port0_data[0]);
-		p->port_type[1] = hex2int(vpd.port1_data[0]);
+		p->port_type[0] = hex_to_bin(vpd.port0_data[0]);
+		p->port_type[1] = hex_to_bin(vpd.port1_data[0]);
 		p->xauicfg[0] = simple_strtoul(vpd.xaui0cfg_data, NULL, 16);
 		p->xauicfg[1] = simple_strtoul(vpd.xaui1cfg_data, NULL, 16);
 	}
 
 	for (i = 0; i < 6; i++)
-		p->eth_base[i] = hex2int(vpd.na_data[2 * i]) * 16 +
-				 hex2int(vpd.na_data[2 * i + 1]);
+		p->eth_base[i] = hex_to_bin(vpd.na_data[2 * i]) * 16 +
+				 hex_to_bin(vpd.na_data[2 * i + 1]);
 	return 0;
 }
 
_
