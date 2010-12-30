From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [net-next-2.6 PATCH v2 4/4] dcbnl: cleanup
Date: Thu, 30 Dec 2010 18:27:10 +0200
Message-ID: <1293726430.29378.95.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John Fastabend" <john.r.fastabend@intel.com>,
	"Eilon Greenstein" <eilong@broadcom.com>, lucy.liu@intel.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1988 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab0L3Q1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 11:27:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of small cleanups for patches:
[net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
[net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
[net-next-2.6 PATCH 3/3] net_dcb: add application notifiers

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 net/dcb/dcbnl.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index b387816..ff3c12d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1626,8 +1626,10 @@ u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	if (new->priority) {
 		struct dcb_app_type *entry;
 		entry = kmalloc(sizeof(struct dcb_app_type), GFP_ATOMIC);
-		if (!entry)
+		if (!entry) {
+			spin_unlock(&dcb_lock);
 			return -ENOMEM;
+		}
 
 		memcpy(&entry->app, new, sizeof(*new));
 		strncpy(entry->name, dev->name, IFNAMSIZ);
@@ -1640,7 +1642,7 @@ out:
 }
 EXPORT_SYMBOL(dcb_setapp);
 
-void dcb_flushapp(void)
+static void dcb_flushapp(void)
 {
 	struct dcb_app_type *app;
 
-- 
1.7.1




