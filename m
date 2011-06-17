From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 6/7] dcb: fix return type on dcb_setapp()
Date: Fri, 17 Jun 2011 14:16:40 -0700
Message-ID: <20110617211640.26578.99416.stgit@jf-dev1-dcblab>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11059 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758014Ab1FQVXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:23:12 -0400
In-Reply-To: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incorrect return type on dcb_setapp() this routine
returns negative error codes. All call sites of
dcb_setapp() assign the return value to an int already
so no need to update drivers.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbnl.h |    2 +-
 net/dcb/dcbnl.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 0a28788..f8c5505 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -28,7 +28,7 @@ struct dcb_app_type {
 	struct list_head  list;
 };
 
-u8 dcb_setapp(struct net_device *, struct dcb_app *);
+int dcb_setapp(struct net_device *, struct dcb_app *);
 u8 dcb_getapp(struct net_device *, struct dcb_app *);
 int dcb_ieee_setapp(struct net_device *, struct dcb_app *);
 int dcb_ieee_delapp(struct net_device *, struct dcb_app *);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 87010ef..28fc386 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1884,7 +1884,7 @@ EXPORT_SYMBOL(dcb_getapp);
  * removes applications from the app list if the priority is
  * set to zero.
  */
-u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
+int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 {
 	struct dcb_app_type *itr;
 	struct dcb_app_type event;

