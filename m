From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPVS] Relax the module get/put in ip_vs_app.c
Date: Mon, 19 Nov 2007 12:58:14 +0300
Message-ID: <47415E36.8030001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60648 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbXKSJ7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 04:59:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both try_module_get/module_put already handle the module == NULL
case, so no need in manual checking.

This patch fits both net-2.6 and net-2.6.25.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 664cb8e..535abe0 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -51,18 +51,13 @@ static DEFINE_MUTEX(__ip_vs_app_mutex);
  */
 static inline int ip_vs_app_get(struct ip_vs_app *app)
 {
-	/* test and get the module atomically */
-	if (app->module)
-		return try_module_get(app->module);
-	else
-		return 1;
+	return try_module_get(app->module);
 }
 
 
 static inline void ip_vs_app_put(struct ip_vs_app *app)
 {
-	if (app->module)
-		module_put(app->module);
+	module_put(app->module);
 }
 
 
