From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH -next] ipv4: af_inet: make it explicitly non-modular
Date: Mon, 11 Jul 2016 16:37:51 -0400
Message-ID: <20160711203751.13516-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:60457 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932259AbcGKUj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 16:39:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Makefile controlling compilation of this file is obj-y,
meaning that it currently is never being built as a module.

Since MODULE_ALIAS is a no-op for non-modular code, we can simply
remove the MODULE_ALIAS_NETPROTO variant used here.

We replace module.h with kmod.h since the file does make use of
request_module() in order to load other modules from here.

We don't have to worry about init.h coming in via the removed
module.h since the file explicitly includes init.h already.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/ipv4/af_inet.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d39e9e47a26e..55513e654d79 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -73,7 +73,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
-#include <linux/module.h>
+#include <linux/kmod.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
@@ -1916,6 +1916,3 @@ static int __init ipv4_proc_init(void)
 	return 0;
 }
 #endif /* CONFIG_PROC_FS */
-
-MODULE_ALIAS_NETPROTO(PF_INET);
-
-- 
2.8.4
