From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: wireless: atmel: Remove open-coded and wrong strcasecmp
Date: Fri, 16 Jan 2015 14:28:27 +0100
Message-ID: <1421414907-26764-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Simon Kelley <simon@thekelleys.org.uk>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel's string library does in fact have strcasecmp, at least
since ded220bd8f08. Moreover, this open-coded version is in fact
wrong: If the strings only differ in their last character, a and b
have already been incremented to point to the terminating nul bytes,
so they would be treated as equal.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/wireless/atmel.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 9183f1cf89a7..55db9f03eb2a 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -45,7 +45,6 @@
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-#include <linux/ctype.h>
 #include <linux/timer.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
@@ -2699,16 +2698,7 @@ static int atmel_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		domain[REGDOMAINSZ] = 0;
 		rc = -EINVAL;
 		for (i = 0; i < ARRAY_SIZE(channel_table); i++) {
-			/* strcasecmp doesn't exist in the library */
-			char *a = channel_table[i].name;
-			char *b = domain;
-			while (*a) {
-				char c1 = *a++;
-				char c2 = *b++;
-				if (tolower(c1) != tolower(c2))
-					break;
-			}
-			if (!*a && !*b) {
+			if (!strcasecmp(channel_table[i].name, domain)) {
 				priv->config_reg_domain = channel_table[i].reg_domain;
 				rc = 0;
 			}
-- 
2.1.3
