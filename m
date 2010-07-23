From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 1/5] drivers: atm: don't use private copy of hex_to_bin()
Date: Fri, 23 Jul 2010 16:18:06 +0300
Message-ID: <244718f934418c4a183e91e333de95ed07c501d4.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54478 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab0GWNSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:18:47 -0400
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
---
 drivers/atm/nicstar.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 729a149..2f3516b 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -154,7 +154,6 @@ static void which_list(ns_dev * card, struct sk_buff *skb);
 #endif
 static void ns_poll(unsigned long arg);
 static int ns_parse_mac(char *mac, unsigned char *esi);
-static short ns_h2i(char c);
 static void ns_phy_put(struct atm_dev *dev, unsigned char value,
 		       unsigned long addr);
 static unsigned char ns_phy_get(struct atm_dev *dev, unsigned long addr);
@@ -2824,9 +2823,9 @@ static int ns_parse_mac(char *mac, unsigned char *esi)
 		return -1;
 	j = 0;
 	for (i = 0; i < 6; i++) {
-		if ((byte1 = ns_h2i(mac[j++])) < 0)
+		if ((byte1 = hex_to_bin(mac[j++])) < 0)
 			return -1;
-		if ((byte0 = ns_h2i(mac[j++])) < 0)
+		if ((byte0 = hex_to_bin(mac[j++])) < 0)
 			return -1;
 		esi[i] = (unsigned char)(byte1 * 16 + byte0);
 		if (i < 5) {
@@ -2837,16 +2836,6 @@ static int ns_parse_mac(char *mac, unsigned char *esi)
 	return 0;
 }
 
-static short ns_h2i(char c)
-{
-	if (c >= '0' && c <= '9')
-		return (short)(c - '0');
-	if (c >= 'A' && c <= 'F')
-		return (short)(c - 'A' + 10);
-	if (c >= 'a' && c <= 'f')
-		return (short)(c - 'a' + 10);
-	return -1;
-}
 
 static void ns_phy_put(struct atm_dev *dev, unsigned char value,
 		       unsigned long addr)
-- 
1.7.1.1

