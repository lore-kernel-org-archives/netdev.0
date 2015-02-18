From: Matthew Thode <mthode@mthode.org>
Subject: [PATCH] reject creation of netdev names with colons
Date: Tue, 17 Feb 2015 18:31:57 -0600
Message-ID: <1424219517-9386-1-git-send-email-mthode@mthode.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matthew Thode <mthode@mthode.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

colons are used as a separator in netdev device lookup in dev_ioctl.c

Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME

Signed-off-by: Matthew Thode <mthode@mthode.org>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d030575..efbad386 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -946,7 +946,7 @@ bool dev_valid_name(const char *name)
 		return false;
 
 	while (*name) {
-		if (*name == '/' || isspace(*name))
+		if (*name == '/' || *name == ':' || isspace(*name))
 			return false;
 		name++;
 	}
-- 
2.0.5
