From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by index
Date: Wed, 16 Dec 2015 13:20:43 -0800
Message-ID: <1450300844-11010-2-git-send-email-dsa@cumulusnetworks.com>
References: <1450300844-11010-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33902 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965604AbbLPVUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 16:20:53 -0500
Received: by mail-pf0-f182.google.com with SMTP id 68so18198596pfc.1
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 13:20:53 -0800 (PST)
In-Reply-To: <1450300844-11010-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add helper to lookup l3mdev master index given a device index.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 774d85b2d5d9..786226f8e77b 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -51,6 +51,24 @@ static inline int l3mdev_master_ifindex(struct net_device *dev)
 	return ifindex;
 }
 
+static inline int l3mdev_master_ifindex_by_index(struct net *net, int ifindex)
+{
+	struct net_device *dev;
+	int rc = 0;
+
+	if (likely(ifindex)) {
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, ifindex);
+		if (dev)
+			rc = l3mdev_master_ifindex_rcu(dev);
+
+		rcu_read_unlock();
+	}
+
+	return rc;
+}
+
 /* get index of an interface to use for FIB lookups. For devices
  * enslaved to an L3 master device FIB lookups are based on the
  * master index
@@ -167,6 +185,11 @@ static inline int l3mdev_master_ifindex(struct net_device *dev)
 	return 0;
 }
 
+static inline int l3mdev_master_ifindex_by_index(struct net *net, int ifindex)
+{
+	return 0;
+}
+
 static inline int l3mdev_fib_oif_rcu(struct net_device *dev)
 {
 	return dev ? dev->ifindex : 0;
-- 
1.9.1
