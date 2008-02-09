From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] libertas: Don't mark exported symbols as static
Date: Fri, 08 Feb 2008 16:07:26 -0800
Message-ID: <adatzkj0z7l.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:49613 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbYBIAQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 19:16:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marking exported symbols as static causes the following build error on
ia64 with gcc 4.2.3:

drivers/net/wireless/libertas/main.c:1375: error: __ksymtab_lbs_remove_mesh causes a section type conflict
drivers/net/wireless/libertas/main.c:1354: error: __ksymtab_lbs_add_mesh causes a section type conflict

Therefore, remove the static marking on lbs_remove_mesh and lbs_add_mesh.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 84fb49c..a688ce8 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -253,8 +253,8 @@ static ssize_t lbs_anycast_set(struct device *dev,
 
 static int lbs_add_rtap(struct lbs_private *priv);
 static void lbs_remove_rtap(struct lbs_private *priv);
-static int lbs_add_mesh(struct lbs_private *priv);
-static void lbs_remove_mesh(struct lbs_private *priv);
+int lbs_add_mesh(struct lbs_private *priv);
+void lbs_remove_mesh(struct lbs_private *priv);
 
 
 /**
@@ -1296,7 +1296,7 @@ EXPORT_SYMBOL_GPL(lbs_stop_card);
  *  @param priv    A pointer to the struct lbs_private structure
  *  @return 	   0 if successful, -X otherwise
  */
-static int lbs_add_mesh(struct lbs_private *priv)
+int lbs_add_mesh(struct lbs_private *priv)
 {
 	struct net_device *mesh_dev = NULL;
 	int ret = 0;
@@ -1354,7 +1354,7 @@ done:
 EXPORT_SYMBOL_GPL(lbs_add_mesh);
 
 
-static void lbs_remove_mesh(struct lbs_private *priv)
+void lbs_remove_mesh(struct lbs_private *priv)
 {
 	struct net_device *mesh_dev;
 
