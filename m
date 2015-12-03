From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 02/28] net: Add support for CHANGEUPPER notifier error injection
Date: Thu,  3 Dec 2015 12:12:04 +0100
Message-ID: <1449141150-8172-3-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33860 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759769AbbLCLMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:40 -0500
Received: by wmvv187 with SMTP id v187so21649016wmv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:39 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since CHANGEUPPER can now fail, add support for it in the newly
introduced netdev notifier error injection infrastructure.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v1->v2:
-new patch
---
 Documentation/fault-injection/notifier-error-inject.txt | 1 +
 lib/netdev-notifier-error-inject.c                      | 1 +
 2 files changed, 2 insertions(+)

diff --git a/Documentation/fault-injection/notifier-error-inject.txt b/Documentation/fault-injection/notifier-error-inject.txt
index 71e638a..83d3f4e 100644
--- a/Documentation/fault-injection/notifier-error-inject.txt
+++ b/Documentation/fault-injection/notifier-error-inject.txt
@@ -103,6 +103,7 @@ Netdevice notifier events which can be failed are:
  * NETDEV_POST_INIT
  * NETDEV_PRECHANGEMTU
  * NETDEV_PRECHANGEUPPER
+ * NETDEV_CHANGEUPPER
 
 Example: Inject netdevice mtu change error (-22 == -EINVAL)
 
diff --git a/lib/netdev-notifier-error-inject.c b/lib/netdev-notifier-error-inject.c
index b2b8566..13e9c62 100644
--- a/lib/netdev-notifier-error-inject.c
+++ b/lib/netdev-notifier-error-inject.c
@@ -18,6 +18,7 @@ static struct notifier_err_inject netdev_notifier_err_inject = {
 		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_POST_INIT) },
 		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_PRECHANGEMTU) },
 		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_PRECHANGEUPPER) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_CHANGEUPPER) },
 		{}
 	}
 };
-- 
1.9.3
