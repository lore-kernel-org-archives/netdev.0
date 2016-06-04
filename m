From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/9] net: dsa: Export suspend/resume functions
Date: Fri,  3 Jun 2016 17:05:27 -0700
Message-ID: <1464998733-10405-8-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35949 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcFDAFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:53 -0400
Received: by mail-pa0-f66.google.com with SMTP id fg1so6941508pad.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:53 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing switch drivers to implement system-wide
suspend/resume functions, export dsa_switch_suspend and
dsa_switch_resume() such that these are callable from the appropriate
driver specific suspend/resume functions.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 14 ++++++++++++++
 net/dsa/dsa.c     |  6 ++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index d6ed5dee73e5..c5abaeda84f3 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -382,4 +382,18 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 
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
index d8cb2acd4f0a..ebc29a1bee08 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -500,7 +500,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 }
 
 #ifdef CONFIG_PM_SLEEP
-static int dsa_switch_suspend(struct dsa_switch *ds)
+int dsa_switch_suspend(struct dsa_switch *ds)
 {
 	int i, ret = 0;
 
@@ -519,8 +519,9 @@ static int dsa_switch_suspend(struct dsa_switch *ds)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(dsa_switch_suspend);
 
-static int dsa_switch_resume(struct dsa_switch *ds)
+int dsa_switch_resume(struct dsa_switch *ds)
 {
 	int i, ret = 0;
 
@@ -542,6 +543,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(dsa_switch_resume);
 #endif
 
 /* platform driver init and cleanup *****************************************/
-- 
2.7.4
