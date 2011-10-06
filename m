From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH 2/3] dcb: add DCBX mode to event notifier attributes
Date: Thu, 06 Oct 2011 11:52:38 -0700
Message-ID: <20111006185238.2781.36917.stgit@jf-dev1-dcblab>
References: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28664 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758965Ab1JFTBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 15:01:40 -0400
In-Reply-To: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DCBX mode to event notifiers so listeners can learn
currently enabled mode.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbnl.h |    1 +
 net/dcb/dcbnl.c     |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 263aa3a..2cd66d0 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -26,6 +26,7 @@ struct dcb_app_type {
 	int	ifindex;
 	struct dcb_app	  app;
 	struct list_head  list;
+	u8	dcbx;
 };
 
 int dcb_setapp(struct net_device *, struct dcb_app *);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index e508593..9bfbc1d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -2075,6 +2075,8 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 
 	event.ifindex = dev->ifindex;
 	memcpy(&event.app, new, sizeof(event.app));
+	if (dev->dcbnl_ops->getdcbx)
+		event.dcbx = dev->dcbnl_ops->getdcbx(dev);
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and replace */
@@ -2152,6 +2154,8 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 
 	event.ifindex = dev->ifindex;
 	memcpy(&event.app, new, sizeof(event.app));
+	if (dev->dcbnl_ops->getdcbx)
+		event.dcbx = dev->dcbnl_ops->getdcbx(dev);
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and abort if found */
@@ -2196,6 +2200,8 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 
 	event.ifindex = dev->ifindex;
 	memcpy(&event.app, del, sizeof(event.app));
+	if (dev->dcbnl_ops->getdcbx)
+		event.dcbx = dev->dcbnl_ops->getdcbx(dev);
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and remove it. */
