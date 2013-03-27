From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 1/2] net: core: let's use native isxdigit instead of custom
Date: Wed, 27 Mar 2013 17:54:13 +0200
Message-ID: <1364399654-9729-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In kernel we have fast and pretty implementation of the isxdigit() function.
Let's use it.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/core/utils.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index e3487e46..3c7f5b5 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/ctype.h>
 #include <linux/inet.h>
 #include <linux/mm.h>
 #include <linux/net.h>
@@ -348,9 +349,7 @@ int mac_pton(const char *s, u8 *mac)
 
 	/* Don't dirty result unless string is valid MAC. */
 	for (i = 0; i < ETH_ALEN; i++) {
-		if (!strchr("0123456789abcdefABCDEF", s[i * 3]))
-			return 0;
-		if (!strchr("0123456789abcdefABCDEF", s[i * 3 + 1]))
+		if (!isxdigit(s[i * 3]) || !isxdigit(s[i * 3 + 1]))
 			return 0;
 		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
 			return 0;
-- 
1.8.2.rc0.22.gb3600c3

