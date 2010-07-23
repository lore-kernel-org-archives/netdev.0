From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 4/5] wireless: use newly introduced hex_to_bin()
Date: Fri, 23 Jul 2010 16:18:09 +0300
Message-ID: <9d7821ff7791c30772667681c0eab829e6e93e59.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Corey Thomas <coreythomas@charter.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52671 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759123Ab0GWNSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:18:50 -0400
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Corey Thomas <coreythomas@charter.net>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
---
 drivers/net/wireless/ray_cs.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index abff893..9c38fc3 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -97,7 +97,6 @@ static iw_stats *ray_get_wireless_stats(struct net_device *dev);
 static const struct iw_handler_def ray_handler_def;
 
 /***** Prototypes for raylink functions **************************************/
-static int asc_to_int(char a);
 static void authenticate(ray_dev_t *local);
 static int build_auth_frame(ray_dev_t *local, UCHAR *dest, int auth_type);
 static void authenticate_timeout(u_long);
@@ -1717,24 +1716,6 @@ static void authenticate_timeout(u_long data)
 }
 
 /*===========================================================================*/
-static int asc_to_int(char a)
-{
-	if (a < '0')
-		return -1;
-	if (a <= '9')
-		return (a - '0');
-	if (a < 'A')
-		return -1;
-	if (a <= 'F')
-		return (10 + a - 'A');
-	if (a < 'a')
-		return -1;
-	if (a <= 'f')
-		return (10 + a - 'a');
-	return -1;
-}
-
-/*===========================================================================*/
 static int parse_addr(char *in_str, UCHAR *out)
 {
 	int len;
@@ -1754,14 +1735,14 @@ static int parse_addr(char *in_str, UCHAR *out)
 	i = 5;
 
 	while (j > 0) {
-		if ((k = asc_to_int(in_str[j--])) != -1)
+		if ((k = hex_to_bin(in_str[j--])) != -1)
 			out[i] = k;
 		else
 			return 0;
 
 		if (j == 0)
 			break;
-		if ((k = asc_to_int(in_str[j--])) != -1)
+		if ((k = hex_to_bin(in_str[j--])) != -1)
 			out[i] += k << 4;
 		else
 			return 0;
-- 
1.7.1.1

