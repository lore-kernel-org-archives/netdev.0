From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH 2/3] net: dcb: use _safe() version of list iterators
Date: Mon, 31 Jan 2011 14:00:54 -0800
Message-ID: <20110131220054.29758.20521.stgit@jf-dev1-dcblab>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47186 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab1AaWFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 17:05:47 -0500
In-Reply-To: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use _safe() version of list iterator macros in dcb_setapp().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 6b03f56..e3399d6 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1605,18 +1605,18 @@ u8 dcb_getapp(struct net_device *dev, struct dcb_app *app)
 EXPORT_SYMBOL(dcb_getapp);
 
 /**
- * ixgbe_dcbnl_setapp - add dcb application data to app list
+ * dcbnl_setapp - add dcb application data to app list
  *
  * Priority 0 is the default priority this removes applications
  * from the app list if the priority is set to zero.
  */
 u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
 {
-	struct dcb_app_type *itr;
+	struct dcb_app_type *itr, *tmp;
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and replace */
-	list_for_each_entry(itr, &dcb_app_list, list) {
+	list_for_each_entry_safe(itr, tmp, &dcb_app_list, list) {
 		if (itr->app.selector == new->selector &&
 		    itr->app.protocol == new->protocol &&
 		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {

