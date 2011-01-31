From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH 3/3] net: dcb: application priority is per net_device
Date: Mon, 31 Jan 2011 14:00:59 -0800
Message-ID: <20110131220059.29758.17857.stgit@jf-dev1-dcblab>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42692 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756237Ab1AaWFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 17:05:52 -0500
In-Reply-To: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The app_data priority may not be the same for all net devices.
In order for stacks with application notifiers to identify the
specific net device dcb_app_type should be passed in the ptr.

This allows handlers to use dev_get_by_name() to pin priority
to net devices.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index e3399d6..249bcec 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1613,6 +1613,10 @@ EXPORT_SYMBOL(dcb_getapp);
 u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
 {
 	struct dcb_app_type *itr, *tmp;
+	struct dcb_app_type event;
+
+	memcpy(&event.name, dev->name, sizeof(event.name));
+	memcpy(&event.app, new, sizeof(event.app));
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and replace */
@@ -1644,7 +1648,7 @@ u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	}
 out:
 	spin_unlock(&dcb_lock);
-	call_dcbevent_notifiers(DCB_APP_EVENT, new);
+	call_dcbevent_notifiers(DCB_APP_EVENT, &event);
 	return 0;
 }
 EXPORT_SYMBOL(dcb_setapp);

