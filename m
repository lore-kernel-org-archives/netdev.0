From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next] slhc: Don't export symbols twice
Date: Fri, 22 Oct 2010 15:41:14 +0000
Message-ID: <20101022154114.GA29603@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:40506 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362Ab0JVPlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Oct 2010 11:41:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't export symbols twice.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/slhc.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/slhc.c b/drivers/net/slhc.c
index ac279fa..ab9e3b7 100644
--- a/drivers/net/slhc.c
+++ b/drivers/net/slhc.c
@@ -688,18 +688,8 @@ slhc_toss(struct slcompress *comp)
 	return 0;
 }
 
-
-/* VJ header compression */
-EXPORT_SYMBOL(slhc_init);
-EXPORT_SYMBOL(slhc_free);
-EXPORT_SYMBOL(slhc_remember);
-EXPORT_SYMBOL(slhc_compress);
-EXPORT_SYMBOL(slhc_uncompress);
-EXPORT_SYMBOL(slhc_toss);
-
 #else /* CONFIG_INET */
 
-
 int
 slhc_toss(struct slcompress *comp)
 {
@@ -738,6 +728,10 @@ slhc_init(int rslots, int tslots)
   printk(KERN_DEBUG "Called IP function on non IP-system: slhc_init");
   return NULL;
 }
+
+#endif /* CONFIG_INET */
+
+/* VJ header compression */
 EXPORT_SYMBOL(slhc_init);
 EXPORT_SYMBOL(slhc_free);
 EXPORT_SYMBOL(slhc_remember);
@@ -745,5 +739,4 @@ EXPORT_SYMBOL(slhc_compress);
 EXPORT_SYMBOL(slhc_uncompress);
 EXPORT_SYMBOL(slhc_toss);
 
-#endif /* CONFIG_INET */
 MODULE_LICENSE("Dual BSD/GPL");
-- 
1.7.0

