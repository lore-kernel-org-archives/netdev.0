From: Dan Carpenter <error27@gmail.com>
Subject: [patch 2/2] dcb: use after free in dcb_flushapp()
Date: Wed, 5 Jan 2011 10:03:44 +0300
Message-ID: <20110105070344.GB24847@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Shmulik Ravid <shmulikr@broadcom.com>,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49097 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab1AEHEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 02:04:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code has a use after free bug because it's not using the
_safe() version of the list_for_each_entry() macro.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 8881cb5..11bf6a2 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1650,9 +1650,10 @@ EXPORT_SYMBOL(dcb_setapp);
 static void dcb_flushapp(void)
 {
 	struct dcb_app_type *app;
+	struct dcb_app_type *tmp;
 
 	spin_lock(&dcb_lock);
-	list_for_each_entry(app, &dcb_app_list, list) {
+	list_for_each_entry_safe(app, tmp, &dcb_app_list, list) {
 		list_del(&app->list);
 		kfree(app);
 	}
