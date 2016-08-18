From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: dsa: Export suspend/resume functions
Date: Thu, 18 Aug 2016 15:30:12 -0700
Message-ID: <1471559416-13249-2-git-send-email-f.fainelli@gmail.com>
References: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33950 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753972AbcHSAtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:49:16 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so2558218pac.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 17:49:16 -0700 (PDT)
In-Reply-To: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing switch drivers to implement system-wide
suspend/resume functions, export dsa_switch_suspend and
dsa_switch_resume() such that these are callable from the appropriate
driver specific suspend/resume functions.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 14 ++++++++++++++
 net/dsa/dsa.c     |  6 ++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2217a3f817f8..d00c392bc9f8 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -386,4 +386,18 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 
 void dsa_unregister_switch(struct dsa_switch *ds);
 int dsa_register_switch(struct dsa_switch *ds, struct device_node *np);
+#ifdef CONFIG_PM_SLEEP
+int dsa_switch_suspend(struct dsa_switch *ds);
+int dsa_switch_resume(struct dsa_switch *ds);
+#else
+static inline int dsa_switch_suspend(struct dsa_switch *ds)
+{
+	return 0;
+}
+static inline int dsa_switch_resume(struct dsa_switch *ds)
+{
+	return 0;
+}
+#endif /* CONFIG_PM_SLEEP */
+
 #endif
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7e68bc6bc853..9f5b47200365 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -543,7 +543,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 }
 
 #ifdef CONFIG_PM_SLEEP
-static int dsa_switch_suspend(struct dsa_switch *ds)
+int dsa_switch_suspend(struct dsa_switch *ds)
 {
 	int i, ret = 0;
 
@@ -562,8 +562,9 @@ static int dsa_switch_suspend(struct dsa_switch *ds)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(dsa_switch_suspend);
 
-static int dsa_switch_resume(struct dsa_switch *ds)
+int dsa_switch_resume(struct dsa_switch *ds)
 {
 	int i, ret = 0;
 
@@ -585,6 +586,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(dsa_switch_resume);
 #endif
 
 /* platform driver init and cleanup *****************************************/
-- 
2.7.4
