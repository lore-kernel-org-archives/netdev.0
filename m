From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 2/2] net/sb1250: remove CONFIG_SIBYTE_STANDALONE
Date: Sun, 25 Apr 2010 23:02:28 +0200
Message-ID: <1272229348-16140-2-git-send-email-sebastian@breakpoint.cc>
References: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
Cc: netdev@vger.kernel.org,
	Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:57841 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751239Ab0DYVCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 17:02:43 -0400
In-Reply-To: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_SIBYTE_STANDALONE is gone since v2.6.31-rc1 ("MIPS: Sibyte:
Remove standalone kernel support")
This is a missing piece.

Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 drivers/net/sb1250-mac.c |  144 ----------------------------------------------
 1 files changed, 0 insertions(+), 144 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index d162862..fc503a1 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -48,23 +48,6 @@
 #include <asm/io.h>
 #include <asm/processor.h>	/* Processor type for cache alignment. */
 
-/* This is only here until the firmware is ready.  In that case,
-   the firmware leaves the ethernet address in the register for us. */
-#ifdef CONFIG_SIBYTE_STANDALONE
-#define SBMAC_ETH0_HWADDR "40:00:00:00:01:00"
-#define SBMAC_ETH1_HWADDR "40:00:00:00:01:01"
-#define SBMAC_ETH2_HWADDR "40:00:00:00:01:02"
-#define SBMAC_ETH3_HWADDR "40:00:00:00:01:03"
-#endif
-
-
-/* These identify the driver base version and may not be removed. */
-#if 0
-static char version1[] __initdata =
-"sb1250-mac.c:1.00 1/11/2001 Written by Mitch Lichtenberg\n";
-#endif
-
-
 /* Operational parameters that usually are not changed. */
 
 #define CONFIG_SBMAC_COALESCE
@@ -2182,85 +2165,6 @@ static void sbmac_setmulti(struct sbmac_softc *sc)
 	}
 }
 
-#if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
-/**********************************************************************
- *  SBMAC_PARSE_XDIGIT(str)
- *
- *  Parse a hex digit, returning its value
- *
- *  Input parameters:
- *  	   str - character
- *
- *  Return value:
- *  	   hex value, or -1 if invalid
- ********************************************************************* */
-
-static int sbmac_parse_xdigit(char str)
-{
-	int digit;
-
-	if ((str >= '0') && (str <= '9'))
-		digit = str - '0';
-	else if ((str >= 'a') && (str <= 'f'))
-		digit = str - 'a' + 10;
-	else if ((str >= 'A') && (str <= 'F'))
-		digit = str - 'A' + 10;
-	else
-		return -1;
-
-	return digit;
-}
-
-/**********************************************************************
- *  SBMAC_PARSE_HWADDR(str,hwaddr)
- *
- *  Convert a string in the form xx:xx:xx:xx:xx:xx into a 6-byte
- *  Ethernet address.
- *
- *  Input parameters:
- *  	   str - string
- *  	   hwaddr - pointer to hardware address
- *
- *  Return value:
- *  	   0 if ok, else -1
- ********************************************************************* */
-
-static int sbmac_parse_hwaddr(char *str, unsigned char *hwaddr)
-{
-	int digit1,digit2;
-	int idx = 6;
-
-	while (*str && (idx > 0)) {
-		digit1 = sbmac_parse_xdigit(*str);
-		if (digit1 < 0)
-			return -1;
-		str++;
-		if (!*str)
-			return -1;
-
-		if ((*str == ':') || (*str == '-')) {
-			digit2 = digit1;
-			digit1 = 0;
-		}
-		else {
-			digit2 = sbmac_parse_xdigit(*str);
-			if (digit2 < 0)
-				return -1;
-			str++;
-		}
-
-		*hwaddr++ = (digit1 << 4) | digit2;
-		idx--;
-
-		if (*str == '-')
-			str++;
-		if (*str == ':')
-			str++;
-	}
-	return 0;
-}
-#endif
-
 static int sb1250_change_mtu(struct net_device *_dev, int new_mtu)
 {
 	if (new_mtu >  ENET_PACKET_SIZE)
@@ -2768,36 +2672,6 @@ static int __exit sbmac_remove(struct platform_device *pldev)
 static struct platform_device **sbmac_pldev;
 static int sbmac_max_units;
 
-#if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
-static void __init sbmac_setup_hwaddr(int idx, char *addr)
-{
-	void __iomem *sbm_base;
-	unsigned long start, end;
-	uint8_t eaddr[6];
-	uint64_t val;
-
-	if (idx >= sbmac_max_units)
-		return;
-
-	start = A_MAC_CHANNEL_BASE(idx);
-	end = A_MAC_CHANNEL_BASE(idx + 1) - 1;
-
-	sbm_base = ioremap_nocache(start, end - start + 1);
-	if (!sbm_base) {
-		printk(KERN_ERR "%s: unable to map device registers\n",
-		       sbmac_string);
-		return;
-	}
-
-	sbmac_parse_hwaddr(addr, eaddr);
-	val = sbmac_addr2reg(eaddr);
-	__raw_writeq(val, sbm_base + R_MAC_ETHERNET_ADDR);
-	val = __raw_readq(sbm_base + R_MAC_ETHERNET_ADDR);
-
-	iounmap(sbm_base);
-}
-#endif
-
 static int __init sbmac_platform_probe_one(int idx)
 {
 	struct platform_device *pldev;
@@ -2874,24 +2748,6 @@ static void __init sbmac_platform_probe(void)
 		return;				/* none */
 	}
 
-	/*
-	 * For bringup when not using the firmware, we can pre-fill
-	 * the MAC addresses using the environment variables
-	 * specified in this file (or maybe from the config file?)
-	 */
-#ifdef SBMAC_ETH0_HWADDR
-	sbmac_setup_hwaddr(0, SBMAC_ETH0_HWADDR);
-#endif
-#ifdef SBMAC_ETH1_HWADDR
-	sbmac_setup_hwaddr(1, SBMAC_ETH1_HWADDR);
-#endif
-#ifdef SBMAC_ETH2_HWADDR
-	sbmac_setup_hwaddr(2, SBMAC_ETH2_HWADDR);
-#endif
-#ifdef SBMAC_ETH3_HWADDR
-	sbmac_setup_hwaddr(3, SBMAC_ETH3_HWADDR);
-#endif
-
 	sbmac_pldev = kcalloc(sbmac_max_units, sizeof(*sbmac_pldev),
 			      GFP_KERNEL);
 	if (!sbmac_pldev) {
-- 
1.6.6.1

